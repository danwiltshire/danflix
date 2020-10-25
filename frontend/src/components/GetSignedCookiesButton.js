import React from 'react';
import { useAuth0 } from '@auth0/auth0-react';

const GetSignedCookiesButton = () => {

    const { isAuthenticated, getAccessTokenSilently } = useAuth0();
    const cloudfrontDistribution = process.env.REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME;

    const getSignedCookies = async () => {
        try {
          const token = await getAccessTokenSilently();
    
          const response = await fetch(`https://${cloudfrontDistribution}/api/signedcookie`, {
            headers: {
              Authorization: `Bearer ${token}`,
            },
            //credentials: "include"
          });
    
          const responseData = await response.json();
    
          console.log("got cookies" + toString(responseData));
        } catch (error) {
          console.error("haven't got cookies");
        }
      };

    

    return (
        isAuthenticated && (
            <button onClick={() => getSignedCookies()}>
                Get Signed Cookies
            </button>
        )
    )
}

export default GetSignedCookiesButton