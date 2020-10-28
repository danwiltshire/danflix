import React from 'react'
import { Logo } from '../components/Logo'
import { useAuth0 } from '@auth0/auth0-react';
import { useHistory } from 'react-router-dom';
import { Footer } from '../components/Footer';
import { Header } from '../components/Header';

interface WelcomeProps {

}

export const Welcome: React.FC<WelcomeProps> = () => {

  const { isAuthenticated, loginWithRedirect, } = useAuth0();

  const history = useHistory();

  return (
    <div>
      <Header profileIcon />
      <main>
        <Logo width='auto' height='56px' />
        <h1>Welcome to Violet</h1>
        <span className="subheading">Your media, serverless.</span>
        { isAuthenticated && <button onClick={() => { history.push('/browse') } }>Browse</button> }
        { ! isAuthenticated && <button onClick={loginWithRedirect}>Log in</button> }
      </main>
      <Footer about />
    </div>
  )
}
