import React from 'react'
import { Logo } from '../components/Logo'

interface WelcomeProps {

}


export const Welcome: React.FC<WelcomeProps> = () => {
  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>Welcome to Violet</h1>
        <span className="subheading">Your media, serverless.</span>
        <button>Log In</button>
      </main>
      <footer>
        <a href="/about">About Violet</a>
      </footer>
    </div>
  );
}
