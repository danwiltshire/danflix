import React from 'react'
import { useHistory } from 'react-router-dom';
import { Logo } from '../components/Logo';

interface HoldingProps {
  heading: string,
  subheading: string,
  browseButton?: boolean
}

export const Holding: React.FC<HoldingProps> = ({ heading, subheading, browseButton }) => {

  const history = useHistory();

  return (
    <div>
      <main>
        <Logo width='auto' height='56px' />
        <h1>{heading}</h1>
        <span className="subheading">{subheading}</span>
        { browseButton && <button onClick={() => { history.push('/browse') } }>Browse</button> }
      </main>
    </div>
  );
}
