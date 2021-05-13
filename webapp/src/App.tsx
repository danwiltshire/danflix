import React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'
import { About } from './views/About'
import { Holding } from './views/Holding'
import { Welcome } from './views/Welcome'
import { Browse } from './views/Browse'
import { Profile } from './views/Profile'
import { Loading } from './views/Loading'
import { useAuth0 } from '@auth0/auth0-react'
import { Notice } from './views/Notice'
import { Player } from './views/Player'
import { PrivacyPolicy } from './views/PrivacyPolicy'
import { FirstRun } from './views/FirstRun'

export const App: React.FC = () => {

  const { isLoading, error } = useAuth0();

  if ( isLoading ) return <Loading />

  if ( error ) {
    return <BrowserRouter>
      <Holding
        heading="Violet is unavailable"
        subheading="Authentication isn't working right now, please check back later."
      />
    </BrowserRouter>
  }
  
  return (
    <BrowserRouter>
      <Switch>
        <Route path="/" exact component={Welcome} />
        <Route path="/about" component={About} />
        <Route path="/browse" component={Browse} />
        <Route path="/profile" component={Profile} />
        <Route path="/loading" component={Loading} />
        <Route path="/notice" component={Notice} />
        <Route path="/player" component={Player} />
        <Route path="/privacy-policy" component={PrivacyPolicy} />
        <Route path="/first-run" component={FirstRun} />
        <Route path="/" render={() => <Holding
            heading={"404 Not Found"}
            subheading={"Violet can't find that."}
            browseButton
          />}
        />
      </Switch>
    </BrowserRouter>
  );
}

export default App;
