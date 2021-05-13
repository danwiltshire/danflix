import React from 'react'
import { Logo } from '../components/Logo'
import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { Setup } from '../components/Setup';

interface FirstRunProps {

}

export const FirstRun: React.FC<FirstRunProps> = () => {
  return (
    <div>
      <Header />
      <main>
        <Logo width='auto' height='56px' />
        <h1>Welcome to Violet</h1>
        <span className="subheading">Your media, serverless.</span>
        <Setup />
      </main>
    </div>
  )
}
