import React from 'react'

type LinkItem = {
  text: string,
  link: string
}

type ListItem = {
  text: string
}

interface ListProps {
  items: Array<LinkItem|ListItem>
}

export const List: React.FC<ListProps> = ({items}) => {
  return (
    <ul>
      {items.map((item: LinkItem | ListItem) => {
        return 'link' in item ? (
          <li><a href={item.link}>{item.text}</a></li>
        ) : (
          <li>{item.text}</li>
        )
      })
    }
    </ul>
  );
}
