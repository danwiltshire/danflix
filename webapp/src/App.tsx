import React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'
import { About } from './routes/About'
import { Holding } from './routes/Holding'
import { Welcome } from './routes/Welcome'
import { Browse } from './routes/Browse'
import { Profile } from './routes/Profile'
import { Loading } from './routes/Loading'
import { HTTP_404 } from './routes/HTTP_404'
import { useAuth0 } from '@auth0/auth0-react'






export const App: React.FC = () => {

  const { isLoading, error } = useAuth0();

  if ( isLoading ) {
    return <Loading />
  }

  if ( error ) {
    return <Holding heading="Violet is unavailable" subheading="Authentication isn't working right now, please check back later." />
  }

  return (
    <BrowserRouter>
      <Switch>
        <Route path="/" exact component={Welcome} />
        <Route path="/about" component={About} />
        <Route path="/holding" component={Holding} />
        <Route path="/browse" component={Browse} />
        <Route path="/profile" component={Profile} />
        <Route path="/loading" component={Loading} />
        <Route path="/" render={() => <HTTP_404 />} />
      </Switch>
    </BrowserRouter>
  );
}

export default App;
