import React from 'react'
import { Logo } from '../components/Logo'
import { Header } from '../components/Header';

interface AboutProps {

}

export const About: React.FC<AboutProps> = () => {
  return (
    <div>
      <Header profileIcon />
      <main>
        <Logo width='auto' height='56px' />
        <h1>Violet</h1>
        <span className="subheading">Your media, serverless.</span>
        <p>Violet is an open source lightweight media hosting solution.  It can be deployed onto Amazon AWS in minutes.</p>
        <button>Deploy</button>
      </main>
    </div>
  );
}
