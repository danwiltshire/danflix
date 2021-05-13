import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { Auth0Provider } from '@auth0/auth0-react';
import { FirstRun } from './views/FirstRun'

const domain = localStorage.getItem('REACT_APP_AUTH0_DOMAIN');
const clientId = localStorage.getItem('REACT_APP_AUTH0_CLIENT_ID');
const audience = localStorage.getItem('REACT_APP_AUTH0_AUDIENCE');
const useRefreshTokens = true;

window.addEventListener("gamepadconnected", (event) => {
  console.log("A gamepad connected:");
  console.log(event.gamepad);
});

window.addEventListener("gamepaddisconnected", (event) => {
  console.log("A gamepad disconnected:");
  console.log(event.gamepad);
});

var gamepads = navigator.getGamepads();
console.log(gamepads);


let requiresSetup = false
if ( ! localStorage.getItem('REACT_APP_AUTH0_DOMAIN') ) requiresSetup = true
if ( ! localStorage.getItem('REACT_APP_AUTH0_CLIENT_ID') ) requiresSetup = true
if ( ! localStorage.getItem('REACT_APP_AUTH0_AUDIENCE') ) requiresSetup = true
if ( ! localStorage.getItem('REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME') ) requiresSetup = true


ReactDOM.render(
  <React.StrictMode>
    { requiresSetup ?
      <FirstRun />
    :
      <Auth0Provider
        domain={domain}
        clientId={clientId}
        redirectUri={window.location.origin}
        audience={audience}
        useRefreshTokens={useRefreshTokens}>
          <App />
      </Auth0Provider>
    }
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
