from typing import Dict, Optional, Tuple, List
import os
from pathlib import Path
import csv
import secrets
from string import Template
import argparse
import posixpath

parser = argparse.ArgumentParser(description='Encrypted HLS transcoder')
parser.add_argument('-s', '--source', help='source file directory', required=True)
parser.add_argument('-d', '--destination', help='destination file directory', required=True)
parser.add_argument('-e', '--extensions', nargs='+', help='extensions to process', default=['mkv'])
parser.add_argument('-p', '--publishurl', help='url where media will be published', required=True)
args = parser.parse_args()

MEDIA_SRC = Path(args.source)
MEDIA_DST = Path(args.destination)
MEDIA_EXTS: Tuple[str, ...] = tuple(args.extensions)
PUBLISH_URL: str = args.publishurl
STATE_FILE = Path('state.csv')
SELF_PARENT_DIR = Path(__file__).parent

class State:
  def __init__(self, stateFile: Path):
    self.stateFile = stateFile

  def get(self, src: Path) -> Optional[Dict[str, str]]:
    reader = csv.DictReader( open( str(self.stateFile) ) )
    for row in reader:
      if row['src'] == str(src):
        return row

  def getAll(self):
    return csv.DictReader( open( str(self.stateFile) ) )

  def write(self, src: Path, dst: Path, iv: str, keyFile: Path, keyInfoFile: Path):
    f = open(self.stateFile, 'a', newline='')
    w = csv.DictWriter(f, ['src', 'dst', 'iv', 'keyfile', 'keyinfofile'])
    if os.stat(self.stateFile).st_size == 0:
      w.writeheader()
    w.writerow({'src': src, 'dst': dst, 'iv': iv, 'keyfile': keyFile, 'keyinfofile': keyInfoFile})
    f.close()

  def create(self):
    with open(self.stateFile, 'a', newline='') as f:
      f.close()

class KeyInfoFile:
  def parseTemplate(self, uri: str, keyFile: str, iv: str) -> str:
    with open( Path(SELF_PARENT_DIR, 'templates', 'hls_key_info_file.tmpl') ) as t:
      return Template(t.read()).substitute(uri=uri, key_name=keyFile, iv=iv)

  def write(self, keyInfoFile: Path, content: str):
    kf = open(keyInfoFile , "w")
    kf.write(content)
    return Path(kf.name)

class Crypto:
  def generateIV(self) -> str:
    return secrets.token_hex(16)

  def _generateKey(self) -> bytes:
    return secrets.token_bytes(16)

  def write(self, keyFile: Path):
    kf = open(keyFile , 'wb')
    kf.write(self._generateKey())
    return Path(kf.name)

  def exist(self, keyFile: Path) -> bool:
    if Path(keyFile).is_file():
      return True
    return False

class Media:
  def get(self) -> List[Path]:
    media: List[Path] = []
    for root, dirs, files in os.walk(MEDIA_SRC, topdown=False):
      for file in files:
        if file.endswith(MEDIA_EXTS):
          media.append( Path(root, file) )
    return media

  def transcode(self, src: Path, dst: Path, kif: Path):
    playlistFilename = Path(dst, "720p.m3u8")
    segmentFilename = Path(dst, "720p_%03d.ts")
    if not os.path.exists(playlistFilename):
      #command = f'ffmpeg -hwaccel auto -i "{src}" -sn -vf scale=w=1280:h=720:force_original_aspect_ratio=decrease -c:a aac -ar 48000 -b:a 128k -c:v h264 -profile:v main -crf 20 -g 192 -keyint_min 192 -sc_threshold 0 -b:v 2500k -maxrate 2675k -bufsize 3750k -hls_time 16 -hls_playlist_type vod -hls_segment_filename "{segmentFilename}" "{playlistFilename}"'
      command = f'ffmpeg -hwaccel auto -i "{src}" -sn -vf scale=w=1280:h=720:force_original_aspect_ratio=decrease -c:a aac -ar 48000 -b:a 128k -c:v h264 -profile:v main -pix_fmt yuv420p -keyint_min 192 -sc_threshold 0 -hls_time 16 -hls_key_info_file "{kif}" -hls_playlist_type vod -hls_segment_filename "{segmentFilename}" "{playlistFilename}"'
      os.system(command)
    else:
      print("transcode(): skipping because m3u8 exists")

# Instantiate classes
keyInfoFile = KeyInfoFile() 
crypto = Crypto()
state = State(STATE_FILE) 
media = Media()

# Create state file
state.create()

# Load media into state file
for file in media.get():
  if not state.get(file):
    iv = crypto.generateIV()
    s = file
    d = Path(MEDIA_DST, iv)
    kf: Path = Path(MEDIA_DST, iv, iv).with_suffix('.key')
    kif: Path = Path(MEDIA_DST, iv, iv).with_suffix('.keyinfofile')
    state.write(s, d, iv, kf, kif)

# Destination directories
for s in state.getAll():
  Path(MEDIA_DST, s['iv']).mkdir(parents=True, exist_ok=True)

# Generate keys
for s in state.getAll():
  if not Path(s['keyfile']).is_file():
    crypto.write(Path(s['keyfile']))

# Generate key info files
for s in state.getAll():
  u = posixpath.join(PUBLISH_URL, s['iv'], s['iv']) + '.key'
  kf = s['keyfile']
  kif = s['keyinfofile']
  iv = s['iv']
  t = keyInfoFile.parseTemplate(u, kf, iv)
  tfp = keyInfoFile.write(Path(kif), t)

# Transcoding
for s in state.getAll():
  src = Path(s['src'])
  dst = Path(s['dst'])
  kif = Path(s['keyinfofile'])
  media.transcode(src, dst, kif)
