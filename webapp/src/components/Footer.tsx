import React from 'react'
import { Link } from 'react-router-dom';

interface FooterProps {
  about?: boolean
}

export const Footer: React.FC<FooterProps> = ({ about }) => {
  return (
    <footer>
      { about && <Link to='/about'>About Violet</Link> }
    </footer>
  );
}
