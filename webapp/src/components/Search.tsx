import React from 'react'

interface SearchProps {

}

export const Search: React.FC<SearchProps> = () => {

  return (
    <div>
      <div className="search">
        <form id="demo-2">
          <input type="search" placeholder="Search" />
        </form>
      </div>
    </div>
  );
}
