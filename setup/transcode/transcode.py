from csv import DictReader
from os import error
from typing import Dict, Tuple
import uuid
import os
from pathlib import Path
import csv
import secrets
from string import Template

source = Path('/mnt/c/Users/DanielWiltshire/Downloads/Media')
destination = Path('destination')
extensions: Tuple[str, ...] = ('.mp4', '.mkv', '.beef')
state = Path('state.csv')

def generateKey() -> int:
  return secrets.randbits(128)

def generateInitVector() -> str:
  return secrets.token_hex(16)

def generateKeyInfoFile(uri: str, key_name: str, iv: str) -> str:
  with open('./templates/hls_key_info_file.tmpl') as t:
    return Template(t.read()).substitute(uri=uri, key_name=key_name, iv=iv)

def transcode(input: Path, output: Path):
  print("transcode(): input: " + str(input))
  print("transcode(): output: " + str(output))
  if not os.path.exists(output):
    os.makedirs(output)
  playlistFilename = Path(str(output) + "/720p.m3u8")
  segmentFilename = Path(str(output) + "/720p_%03d.ts")
  if not os.path.exists(playlistFilename):
    command = f'ffmpeg -hwaccel auto -i "{input}" -sn -vf scale=w=1280:h=720:force_original_aspect_ratio=decrease -c:a aac -ar 48000 -b:a 128k -c:v h264 -profile:v main -crf 20 -g 192 -keyint_min 192 -sc_threshold 0 -b:v 2500k -maxrate 2675k -bufsize 3750k -hls_time 16 -hls_playlist_type vod -hls_segment_filename "{segmentFilename}" "{playlistFilename}"'
    os.system(command)
  else:
    print("transcode(): skipping because m3u8 exists")

def getState(input: Path):
  print("getState(): " + str(input))
  try:
    with open(state) as csvfile:
      reader = csv.DictReader(csvfile)
      for row in reader:
        if row['input'] == str(input):
          return row['random']
  except:
    raise Exception("getState(): couldn't get: " + str(input))

def initState(state: Path):
  if not os.path.exists(state):
    print("initState(): initialising: " + str(state))
    try:
      with open(state, 'w', newline='') as csvfile:
        fieldnames = ['input', 'random']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
    except:
      raise Exception("initState() couldn't initialise: " + str(state))

def writeState(input: Path, random: str):
  print("writeState(): writing: " + str(input))
  try:
    with open(state, 'a', newline='') as csvfile:
      fieldnames = ['input', 'random']
      writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
      writer.writerow({'input': str(input), 'random': random})
  except:
    raise Exception("writeState() couldn't write: " + str(input))

# Create state file
initState(state)

for root, dirs, files in os.walk(source, topdown=False):
  for file in files:
    if file.endswith(extensions):
      random = str(uuid.uuid4())
      iv = generateInitVector()
      input: Path = Path(root + '/' + file)
      existingRand = getState(input)
      existingIV = getState(iv)
      if not existingRand: # No state exists, use new random
        writeState(input, random)
        output: Path = Path(str(destination) + '/' + random)
        transcode(input, output)
        if not Path(output, 'k').is_file():
          print(generateKeyInfoFile(f"https://d3ss7civfz2zg0.cloudfront.net/media/{random}/k", random))
      if existingRand: # State exists, use existing random
        output: Path = Path(str(destination) + '/' + existingRand)
        transcode(input, output)
        if not Path(output, 'k').is_file():
          print(generateKeyInfoFile(f"https://d3ss7civfz2zg0.cloudfront.net/media/{existingRand}/k", existingRand))
      #print("Would transcode")
      #transcode(input, output)




#(
#  ffmpeg
#  .input('./source/')
#  .output('./destination/', format='hls', hls_time=16, hls_playlist_type='vod')
#)


#input = ffmpeg.input(file)
