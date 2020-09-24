import React, { useState, useEffect } from 'react';
import { useAuth0 } from '@auth0/auth0-react';
import axios from 'axios';

function GetData() {
    const [data, setData] = useState({ hits: [] });
   
    useEffect(() => {
        const fetchData = async () => {
          const result = await axios(
            'https://hn.algolia.com/api/v1/search?query=redux',
          );
     
          setData(result.data);
        };
     
        fetchData();
      }, []);
   
    return (
      <ul>
        {data.hits.map(item => (
          <li key={item.objectID}>
            <a href={item.url}>{item.title}</a>
          </li>
        ))}
      </ul>
    );
  }
   

const Media = () => {
    const { isAuthenticated } = useAuth0();

    return (
        !isAuthenticated && (
            GetData()
        )
    )
}

export default Media