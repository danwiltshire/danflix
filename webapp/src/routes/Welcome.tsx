import React from 'react'
import { Logo } from '../components/Logo'
import { useAuth0 } from '@auth0/auth0-react';
import { RouteComponentProps } from 'react-router-dom';

interface WelcomeProps extends RouteComponentProps {

}

export const Welcome: React.FC<WelcomeProps> = ({ history }) => {

  const {
    isAuthenticated,
    loginWithRedirect,
    user,
  } = useAuth0();

  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>Welcome to Violet</h1>
        <span className="subheading">Your media, serverless.</span>
        {isAuthenticated ? (
          <div>
            <p>Logged in as {user.name}</p>
            <button onClick={() => { history.push('/browse') } }>Browse media</button>
          </div>
        ) : (
          <button onClick={loginWithRedirect}>Log In</button>
        )}
      </main>
      <footer>
        <a href="/about">About Violet</a>
      </footer>
    </div>
  )
}
