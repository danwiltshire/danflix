import React from 'react'
import { List } from '../components/List'
import { Logo } from '../components/Logo'

interface ProfileProps {

}

const listItems = [
  { text: "Auth method: google-oauth2" },
  { text: "Environment: dev" }
]

export const Profile: React.FC<ProfileProps> = () => {
  return (
    <div>
      <header>
        <a href="https://github.com/danwiltshire/Violet">Back</a>
      </header>
      <main>
        <Logo width='auto' height='56px' />
        <h1>User Full Name</h1>
        <List items={listItems} />
        <button>Log Out</button>
      </main>
      <footer>
        <a href="/about">About Violet</a>
      </footer>
    </div>
  );
}
