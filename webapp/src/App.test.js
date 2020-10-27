import { render, screen } from '@testing-library/react';
import { About } from './routes/About';
import { Holding } from './routes/Holding';
import { Browse } from './routes/Browse';
import { Profile } from './routes/Profile';
import { Welcome } from './routes/Welcome';

test('renders about route', () => {
  render(<About />);
  const linkElement = screen.getByText(/Violet is an open source lightweight media hosting solution/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders holding route', () => {
  render(<Holding />);
  const linkElement = screen.getByText(/Sorry, the API isn't responding. Please check back later./i);
  expect(linkElement).toBeInTheDocument();
});

test('renders browse route', () => {
  render(<Browse />);
  const linkElement = screen.getByText(/A link to nothing/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders profile route', () => {
  render(<Profile />);
  const linkElement = screen.getByText(/User Full Name/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders welcome route', () => {
  render(<Welcome />);
  const linkElement = screen.getByText(/Welcome to Violet/i);
  expect(linkElement).toBeInTheDocument();
});
