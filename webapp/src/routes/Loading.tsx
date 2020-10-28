import React from 'react'
import { Logo } from '../components/Logo';

interface LoadingProps {

}

export const Loading: React.FC<LoadingProps> = ({}) => {
  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>Loading Violet</h1>
        <span className="subheading">Please standby...</span>
      </main>
    </div>
  );
}
