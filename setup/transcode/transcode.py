from typing import Dict, Tuple, List
import os
from pathlib import Path
import csv
import secrets
from string import Template

source = Path('/mnt/c/Users/danielwiltshire/Downloads/Featurettes')
destination = Path('destination')
extensions: Tuple[str, ...] = ('.mp4', '.mkv', '.beef')
state = Path('state.csv')

class State:
  def __init__(self, statePath: Path):
    self.statePath = statePath
    fields: List[str] = ['source', 'iv']
    if not os.path.exists( str(self.statePath) ):
      open(statePath, 'a').close()
    self.writer = csv.DictWriter(
      open( str(self.statePath), 'a', newline='' ),
      fieldnames=fields)
    if os.stat(statePath).st_size == 0:
      self.writer.writeheader()

  def get(self, source: str) -> List[Dict[str, str]]:
    matches: List[Dict[str, str]] = []
    reader = csv.DictReader( open( str(self.statePath) ) )
    for row in reader:
      if row['source'] == str(source):
        matches.append(row)
    return matches

  def write(self, source: str, iv: str):
    print(source)
    self.writer.writerow({'source': source, 'iv': iv})

  def isValid(self, row: Dict[str, str]) -> bool:
    if not len(row['iv']) == 32:
      print("Failed to validate iv length", len(row['iv']))
      return False
    if not row['iv'].isalnum():
      print("Failed to validate iv row alphanumerics")
      return False
    return True
 
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
    #command = f'ffmpeg -hwaccel auto -i "{input}" -sn -vf scale=w=1280:h=720:force_original_aspect_ratio=decrease -c:a aac -ar 48000 -b:a 128k -c:v h264 -profile:v main -crf 20 -g 192 -keyint_min 192 -sc_threshold 0 -b:v 2500k -maxrate 2675k -bufsize 3750k -hls_time 16 -hls_playlist_type vod -hls_segment_filename "{segmentFilename}" "{playlistFilename}"'
    command = f'ffmpeg -hwaccel auto -i "{input}" -keyint_min 192 -sc_threshold 0 -hls_time 16 -hls_playlist_type vod -hls_segment_filename "{segmentFilename}" "{playlistFilename}"'
    os.system(command)
  else:
    print("transcode(): skipping because m3u8 exists")

# Create state file
state = State( Path('state.csv')) 

for root, dirs, files in os.walk(source, topdown=False):
  for file in files:
    if file.endswith(extensions):
      writeState: bool = False
      stateIV: str = ""
      outputPath: Path
      print(f"{file}:")

      print("...joining source path")
      sourcePath: Path = Path(root + '/' + file)

      print("...getting state")
      fileStates = state.get( str(sourcePath) )

      if len(fileStates) > 1:
        print("...multiple state entries found")
        raise RuntimeError(f"duplicate state entries found for {file}")

      if len(fileStates) == 0:
        print("...no existing state")
        writeState = True

      for fileState in fileStates:
        print("...found state record")

        print("...validate state")
        if state.isValid(fileState):
          print("...state is valid")
          stateIV = fileState['iv']
        else:
          raise RuntimeError(f"invalid state for {file}")

      if writeState:
        print("...writing state")
        stateIV = secrets.token_hex(16)
        state.write( str(sourcePath), stateIV )

      if len(stateIV) == 32:
        outputPath = Path(str("destination") + '/' + stateIV)
      else:
        raise RuntimeError("...stateIV is invalid")
      
      if Path(outputPath).is_file():
        print("...transcode exists")
      else:
        print(f"...transcoding source: {sourcePath}")
        print(f"...transcoding output: {outputPath}")
        Path(outputPath).mkdir(parents=True, exist_ok=True)
        print("...starting transcode")
        transcode(sourcePath, outputPath)
