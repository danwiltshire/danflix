import React, { useEffect, useState } from 'react';
import { List } from '../components/List'
import { useAuth0 } from '@auth0/auth0-react';
import { Welcome } from './Welcome';
import { Header } from '../components/Header';
import { Holding } from './Holding';
import { Loading } from './Loading';
import { Link, RouteComponentProps } from 'react-router-dom';

interface BucketItem {
  ETag: string
  Key: string
  LastModified: string
  Size: number
  StorageClass: string
}

/*const listItems = [
  { text: "Making of Aja", link: "/player" }
]*/

export const Browse: React.FC = () => {

  const { isAuthenticated, getAccessTokenSilently } = useAuth0();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [data, setData] = useState<BucketItem[]>([]);

  useEffect(() => {

    const listBucket = async () => {
      try {
        const accessToken = await getAccessTokenSilently()

        const response = await fetch(`https://d3ss7civfz2zg0.cloudfront.net/api/listbucket`, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });

        const data = await response.json()

        setLoading(false)
        setData(data)
        console.log(data)
      } catch (e) {
        console.log(e.message)
        setError(true)
      }
    }

    listBucket()
  }, [])

  if ( isAuthenticated ) {


    return (
      <div>
      <Header logo profileIcon />
      {
      error ?
        <Holding heading={"Media unavailable"} subheading={"Couldn't get available media."} />
      :
      loading ?
        <Loading />
      :
        <div>
          <main>
            <h1>Browse</h1>
            <ul>
            { data.map((item) => (
              <li className="linkItem" key={item.Key}><Link to={{ pathname: '/player', state: { bucketKey: item.Key } }}>{item.Key}</Link></li>
            ))}
            </ul>
          </main>
        </div>
      }
    </div>
    )
  } else {
    return (
      <Welcome />
    )
  }
}
