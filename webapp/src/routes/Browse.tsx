import React from 'react';
import { List } from '../components/List'

interface BrowseProps {

}

const listItems = [
  { text: "A link to BBC", link: "https://www.bbc.co.uk/" },
  { text: "A link to Google", link: "https://www.google.co.uk/" },
  { text: "A link to nothing", link: "http://localhost:3000" }
]

export const Browse: React.FC<BrowseProps> = () => {
  return (
    <div>
      <header>
        <a href="https://github.com/danwiltshire/Violet">Back</a>
      </header>
      <main>
        <h1>Browse</h1>
        <List
            items={
              listItems
            }
          />
      </main>
    </div>
  );
}
