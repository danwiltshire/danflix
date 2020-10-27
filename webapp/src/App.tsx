import React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'
import { About } from './routes/About'
import { Holding } from './routes/Holding'
import { Welcome } from './routes/Welcome'
import { Browse } from './routes/Browse'
import { Profile } from './routes/Profile'

export const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Switch>
        <Route path="/" exact component={Welcome} />
        <Route path="/about" component={About} />
        <Route path="/holding" component={Holding} />
        <Route path="/browse" component={Browse} />
        <Route path="/profile" component={Profile} />
      </Switch>
    </BrowserRouter>
  );
}

export default App;
