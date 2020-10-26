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
          <div className="counter">
            <div>{count}</div>
            <button onClick={() => setCount(count + 1)}>+</button>
          </div>
        )}
      </Counter>
      <hr />
      <Button />
      <hr />
      <Logo
        width='auto'
        height='42px'
      />
      <Logo
        width='auto'
        height='56px'
      />
      <hr />
      <div className="list">
        <List
          items={
            listItems
          }
        />
      </div>
      <hr />
      <h1>Heading 1</h1>
      <span className="subheading">Subheading</span>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Expedita at repudiandae mollitia a quas impedit. Provident expedita inventore sint optio assumenda perferendis nostrum est necessitatibus ex quos, doloremque porro. Tempore?</p>
      <hr />
      <a href="https://github.com/danwiltshire/Violet">About Violet</a>
    </div>
  );
}

export default App;
