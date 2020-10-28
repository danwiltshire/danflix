import React from 'react';
import { List } from '../components/List'
import { useAuth0 } from '@auth0/auth0-react';
import { Welcome } from './Welcome';
import { Header } from '../components/Header';

interface BrowseProps {

}

const listItems = [
  { text: "A link to BBC", link: "https://www.bbc.co.uk/" },
  { text: "A link to Google", link: "https://www.google.co.uk/" },
  { text: "A link to nothing", link: "http://localhost:3000" }
]

export const Browse: React.FC<BrowseProps> = () => {

  const { isAuthenticated } = useAuth0();

  if ( isAuthenticated ) {
    return (
      <div>
        <Header profileIcon />
        <main>
          <h1>Browse</h1>
          <List items={ listItems } />
        </main>
      </div>
    )
  } else {
    return (
      <Welcome />
    )
  }
}
