import React from 'react'
import { Logo } from '../components/Logo'
import { Header } from '../components/Header';

interface PrivacyPolicyProps {

}

export const PrivacyPolicy: React.FC<PrivacyPolicyProps> = () => {
  return (
    <div>
      <Header profileIcon />
      <main>
        <Logo width='auto' height='56px' />
        <h1>Violet</h1>
        <span className="subheading">Your media, serverless.</span>

        <h2>Privacy Policy</h2>

        <p>Violet Webapp (this web application) does not collect any personal information.</p>
        
        <h3>Cookies</h3>
        <p>Violet uses 'session token' cookies to keep you signed in. They do not contain any personal information.</p>
      </main>
    </div>
  );
}
