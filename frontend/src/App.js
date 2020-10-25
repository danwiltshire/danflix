import React from 'react';
import './App.css';
import LoginButton from './components/LoginButton';
import LogoutButton from './components/LogoutButton';
import GetSignedCookiesButton from './components/GetSignedCookiesButton';
import GetProtectedResourceButton from './components/GetProtectedResourceButton';
import { useAuth0 } from '@auth0/auth0-react';

function App() {
  const { isLoading } = useAuth0();

  if (isLoading) return <div>Loading...</div>
  
  return (
    <>
      <LoginButton />
      <LogoutButton />
      <GetSignedCookiesButton />
      <GetProtectedResourceButton />
    </>
  );
}

export default App;
