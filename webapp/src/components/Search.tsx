import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

interface SearchProps {

}

export const Search: React.FC<SearchProps> = ({}) => {

  const [expanded, setExpanded] = useState(false)

  const expand = () => {
    setExpanded(true)
  }

  return (
    <div>
      <div className="search">
        <form id="demo-2">
          <input type="search" placeholder="Search" onFocus={() => setExpanded} />
        </form>
      </div>
    </div>
  );
}
