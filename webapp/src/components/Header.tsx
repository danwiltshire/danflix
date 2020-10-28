import React from 'react'
import { useAuth0 } from '@auth0/auth0-react'
import { Logo } from './Logo';
import { Link } from 'react-router-dom';

interface HeaderProps {
  logo?: boolean,
  profileIcon?: boolean
}

export const Header: React.FC<HeaderProps> = ({ logo, profileIcon }) => {

  const { isAuthenticated, user } = useAuth0();

  return (
    <header>
      { logo && <Link to='/'><Logo width='auto' height='40px' /></Link> }
      { isAuthenticated && profileIcon && <Link to='/profile'><img src={user.picture} alt={"Profile icon for " + user.name} height='56px' /></Link> }
    </header>
  );
}
