#!/bin/bash -e

# macOS: brew install bash
#        Usage: /usr/local/bin/bash transcode.sh
#        Why:   Required for globstar support

shopt -s globstar

inputfolder="$1"
outputfolder="$2"
dryrun=false

for v in $inputfolder/**/*.{avi,mkv,mp4}; do
  if [ -f "$v" ]; then
    # Substitute variables to get the identical output folder
    o=${v/$inputfolder/$outputfolder}
    withoutextension="${v%.*}"
    destwithoutextension="${o%.*}"

    # Create directories
    if [ "$dryrun" = false ]; then
      echo "mkdir $destwithoutextension"
      mkdir -p "$destwithoutextension"
    else
      echo "Would mkdir -p $destwithoutextension"
    fi

    # Find and copy .nfo
    if [ -f "$withoutextension.nfo" ] && [ "$dryrun" = false ]; then
      echo "cp $withoutextension.nfo"
      cp "$withoutextension.nfo" "$destwithoutextension/"
    else
      echo "Would cp $withoutextension.nfo -> $destwithoutextension/"
    fi

    # Transcode media
    if [ "$dryrun" = false ]; then
      echo "transcode $v"
      ffmpeg -hwaccel auto \
      -i "$v" \
      -vf scale=w=1280:h=720:force_original_aspect_ratio=decrease \
      -c:a aac -ar 48000 -b:a 128k \
      -c:v h264 -profile:v main -crf 20 \
      -g 192 -keyint_min 192 \
      -sc_threshold 0 \
      -b:v 2500k -maxrate 2675k -bufsize 3750k \
      -hls_time 16 \
      -hls_playlist_type vod \
      -hls_segment_filename "$destwithoutextension/720p_%03d.ts" "$destwithoutextension/720p.m3u8"
    else
      echo "Would transcode $v -> $destwithoutextension/720p.m3u8"
    fi
  fi
done
