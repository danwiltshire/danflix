import React, { useEffect, useState } from 'react'
import { VideoPlayer } from '../components/VideoPlayer';
import { useAuth0 } from '@auth0/auth0-react';
import { Loading } from './Loading';
import { Holding } from './Holding';
import { Header } from '../components/Header';
import { useLocation } from 'react-router-dom';

// The 'state' passed from <Link state: (react-router-dom)
interface stateType {
  bucketKey: string
}

export const Player: React.FC = () => {

  const { getAccessTokenSilently } = useAuth0();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);


  const { state } = useLocation<stateType>()
  console.log(state.bucketKey) // runs twice??

  useEffect(() => {

    const doCookiesExist = (): Boolean => {
      if (document.cookie.split(';').some((item) => item.trim().startsWith('CloudFront-Key-Pair-Id='))) {
        setLoading(false)
        return true
      } else {
        return false
      }
    }

    const getSignedCookies = async () => {
      try {
        const accessToken = await getAccessTokenSilently()

        await fetch(`https://${localStorage.getItem('REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME')}/api/signedcookie`, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });

        setLoading(false)
      } catch (e) {
        console.log(e.message)
        setError(true)
      }
    }

    if ( doCookiesExist() ) {
      console.log("doCookiesExist() evaluated true");
    } else {
      console.log("doCookiesExist() evaluated false");
      getSignedCookies()
    }
  }, [])

  const videoJsOptions = {
    autoplay: true,
    controls: true,
    sources: [{
      src: `https://${localStorage.getItem('REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME')}/${state.bucketKey}`,
      type: 'application/x-mpegURL',
      withCredentials: true
    }],
  };

  return (
    <div>
      <Header logo profileIcon />
      {
      error ?
        <Holding heading={"Media unavailable"} subheading={"Couldn't get authentication cookies."} />
      :
      loading ?
        <Loading />
      :
        <VideoPlayer videoJsOptions={videoJsOptions} />
      }
    </div>
  );
}
