import React, { useEffect, useState } from 'react';
import { useAuth0 } from '@auth0/auth0-react';

const AWSListObjects = () => {
  const { getAccessTokenSilently } = useAuth0();
  const [posts, setPosts] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        const token = await getAccessTokenSilently({
          audience: 'https://ghwwj4hvm4.execute-api.eu-west-2.amazonaws.com/'
        });
        const response = await fetch('https://ghwwj4hvm4.execute-api.eu-west-2.amazonaws.com/listobjects', {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        setPosts(await response.json());
      } catch (e) {
        console.error(e);
      }
    })();
  }, [getAccessTokenSilently]);

  if (!posts) {
    return <div>Loading...</div>;
  }

  return (
    <ul>
      {posts.map((post, index) => {
        return <li key={index}>{post}</li>;
      })}
    </ul>
  );
};

export default AWSListObjects;