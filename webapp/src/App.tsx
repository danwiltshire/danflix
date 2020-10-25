import React from 'react'
import { Button } from './components/Button'
import { Counter } from './components/Counter'
import { Logo } from './components/Logo'

export const App: React.FC = () => {
  return (
    <div>
      <Counter>
        {(count, setCount) => (
          <div>
            {count}
            <button onClick={() => setCount(count + 1)}>+</button>
          </div>
        )}
      </Counter>
      <Button />
      <Logo
        width='auto'
        height='42px'
      />
    </div>
  );
}

export default App;
