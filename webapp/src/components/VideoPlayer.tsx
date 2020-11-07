import React, { useEffect, useRef } from 'react'
import videojs from 'video.js'
import 'video.js/dist/video-js.css';

interface VideoPlayerProps {
  videoJsOptions: videojs.PlayerOptions;
}

export const VideoPlayer: React.FC<VideoPlayerProps> = ({videoJsOptions}) => {

  const playerRef = useRef() as React.MutableRefObject<HTMLVideoElement>
  //const [ props ] = useState<PlayerProps>()
  //let { player, videoNode } = useState(VideoJsPlayer);

  useEffect(() => {
    const player = videojs(playerRef.current, videoJsOptions, function onPlayerReady() {
      console.log('onPlayerReady', player)
    });
    return () => {
      if (player) {
        player.dispose()
      }
    }
  }, [])

  return (
    <div>	
      <div data-vjs-player>
        <video ref={playerRef} className="video-js"></video>
      </div>
    </div>
  );
}
