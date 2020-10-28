import React from 'react'
import { Logo } from '../components/Logo';

interface HTTP_404Props {

}

export const HTTP_404: React.FC<HTTP_404Props> = ({}) => {
  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>404 Not Found</h1>
        <span className="subheading">Sorry, Violet can't find that.</span>
      </main>
    </div>
  );
}
