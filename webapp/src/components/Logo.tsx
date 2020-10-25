import React from 'react'

interface LogoProps {
  width: string,
  height: string
}



export const Logo: React.FC<LogoProps> = ({width, height}) => {
  return (
    <svg width={width} height={height} viewBox="0 0 80 56" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="80" height="47.2889" rx="2" fill="url(#paint0_linear)"/>
      <rect x="25.8461" y="51.0222" width="29.5385" height="4.97778" rx="1" fill="#6A61D6"/>
      <defs>
      <linearGradient id="paint0_linear" x1="-45.3493" y1="25.2255" x2="0.272524" y2="97.5679" gradientUnits="userSpaceOnUse">
      <stop stop-color="#EE82EE"/>
      <stop offset="1" stop-color="#6A61D6"/>
      </linearGradient>
      </defs>
    </svg>
  );
}
