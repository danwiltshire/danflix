import React from 'react'
import { Logo } from '../components/Logo';

interface HoldingProps {
  heading: string,
  subheading: string
}

export const Holding: React.FC<HoldingProps> = ({heading, subheading}) => {
  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>{heading}</h1>
        <span className="subheading">{subheading}</span>
      </main>
    </div>
  );
}
