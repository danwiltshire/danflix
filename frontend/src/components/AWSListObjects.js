import React, { useState, useEffect } from 'react';
import { useAuth0 } from '@auth0/auth0-react';
import axios from 'axios';

function GetData() {
    const [data, setData] = useState({ Contents: [] });
   
    useEffect(() => {
        const fetchData = async () => {
          const result = await axios(
            'https://62vdqtbnec.execute-api.eu-west-2.amazonaws.com/danflix-listObjects',
          );
            console.log(result.data)
          setData(result.data);
        };
     
        fetchData();
      }, []);
   
    return (
      <ul>
        {data.Contents.map(item => (
          <li key={item.Key}>
            <a href={item.Key}>{item.Key}</a>
          </li>
        ))}
      </ul>
    );
  }
   

const AWSListObjects = () => {
    const { isAuthenticated } = useAuth0();

    return (
        !isAuthenticated && (
            GetData()
        )
    )
}

export default AWSListObjects