import React, { useState } from "react";
import { Button, ButtonGroup, Container } from "react-bootstrap";
import { useAuth0 } from "@auth0/auth0-react";
import JSONPretty from "react-json-pretty";
import { useVideojs } from 'react-videojs-hook';
import 'video.js/dist/video-js.css';


const VideoPlayer = () => {
  const onPlay = (currentTime) => {
    console.log("Video played at: ", currentTime);
  };
 
  const onPause = (currentTime) => {
    console.log("Video paused at: ", currentTime);
  };
 
  const onEnd = (currentTime) => {
    console.log(`Video ended at ${currentTime}`);
  };
 
  const onTimeUpdate = (currentTime) => {
    console.log(`Video current time is ${currentTime}`)
  };
 
  const { vjsId, vjsRef, vjsClassName } = useVideojs({
    src: 'https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/presignedurl?key=Brooklyn Nine-Nine (2013)/Season 1/Brooklyn Nine-Nine - S01E01 - Pilot 720p AAC/720p.m3u8',
    controls: true,
    autoplay: true,
    responsive: true,
    bigPlayButtonCentered: true,
    onPlay,
    onPause,
    onEnd,
    onTimeUpdate,
  });
 
 
  // wrap the player in a div with a `data-vjs-player` attribute
  // so videojs won't create additional wrapper in the DOM
  // see https://github.com/videojs/video.js/pull/3856
  return (
    <div data-vjs-player>
      <video ref={vjsRef} id={vjsId} className={vjsClassName}></video>
    </div>
  )
}


export const AWSGetPresignedURL = () => {
  const [messages, setMessage] = useState("");

  const { getAccessTokenSilently } = useAuth0();

  const callSecureApi = async () => {
    try {
      const token = await getAccessTokenSilently();

      const response = await fetch(`https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/presignedurl?key=Brooklyn Nine-Nine (2013)/Season 1/Brooklyn Nine-Nine - S01E01 - Pilot 720p AAC/720p.m3u8`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const responseData = await response.json();

      setMessage(responseData);
    } catch (error) {
      setMessage(error.message);
    }
  };

  return (
    <Container className="mb-5">
      <h1>External API</h1>
      <ButtonGroup>
        <Button onClick={callSecureApi} color="primary" className="mt-5">
          List Storage
        </Button>
      </ButtonGroup>

      {messages && (
        <div className="mt-5">
          <h6 className="muted">Result</h6>

          <VideoPlayer />

          { messages }

          <JSONPretty data={messages} onJSONPrettyError={e => console.error(e)}></JSONPretty>
        </div>
      )}
    </Container>
  );

};

export default AWSGetPresignedURL;
