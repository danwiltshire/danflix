import React from 'react'
import { List } from '../components/List'
import { useAuth0 } from '@auth0/auth0-react';
import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { Welcome } from './Welcome';

interface ProfileProps {

}


export const Profile: React.FC<ProfileProps> = () => {

  const {
    isAuthenticated,
    logout,
    user
  } = useAuth0();
  
  if ( isAuthenticated ) {

    const listItems = [
      { text: "Email: " + user.email },
      { text: "Auth type: " + user.sub }
    ]

    return (
      <div>
        <Header logo />
        <main>
          <img src={user.picture} alt={user.name} height='56px' />
          <h1>{user.nickname}</h1>
          <List items={listItems} />
          <button onClick={() => logout({ returnTo: window.location.origin })}>Log Out</button>
        </main>
        <Footer />
      </div>
    )
  } else {
    return (
      <Welcome />
    )
  }
}
