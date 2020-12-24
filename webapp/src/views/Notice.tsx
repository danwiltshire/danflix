import React from 'react'
import { Logo } from '../components/Logo';

interface NoticeProps {
  heading: string,
  subheading: string
}

export const Notice: React.FC<NoticeProps> = ({heading, subheading}) => {

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
