import React from 'react'
import { Logo } from '../components/Logo';

interface HoldingProps {

}

export const Holding: React.FC<HoldingProps> = () => {
  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>Violet is unavailable</h1>
        <span className="subheading">Sorry, the API isn't responding. Please check back later.</span>
      </main>
    </div>
  );
}
