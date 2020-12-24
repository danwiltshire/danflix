import React, { useState } from 'react'
import { useAuth0 } from '@auth0/auth0-react'
import { Logo } from './Logo';
import { Link } from 'react-router-dom';
import { Search } from './Search';

interface HeaderProps {
  logo?: boolean,
  profileIcon?: boolean,
  search?: boolean
}

export const Header: React.FC<HeaderProps> = ({ logo, profileIcon, search }) => {

  const { isAuthenticated, user } = useAuth0();

  const [expanded, setExpanded] = useState(false)

  const expand = () => {
    setExpanded(true)
  }

  return (
    <header>
      { logo && <Link to='/'><Logo width='auto' height='40px' /></Link> }
      { search && <Search /> }
      { isAuthenticated && profileIcon && <Link to='/profile'><img src={user.picture} alt={"Profile icon for " + user.name} height='56px' /></Link> }
    </header>
  );
}
