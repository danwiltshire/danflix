import React from 'react'
import { Button } from './components/Button'
import { Counter } from './components/Counter'
import { List } from './components/List'
import { Logo } from './components/Logo'

export const App: React.FC = () => {

  const listItems = [
    { text: "A link to BBC", link: "https://www.bbc.co.uk/" },
    { text: "A link to Google", link: "https://www.google.co.uk/" },
    { text: "Just a list item" },
    { text: "Another list item" },
    { text: "A link to nothing", link: "http://localhost:3000" }
  ]

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
      <List
        items={
          listItems
        }
      />
    </div>
  );
}

export default App;
