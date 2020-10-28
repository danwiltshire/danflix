import { render, screen } from '@testing-library/react';
import { About } from './routes/About';
import { Holding } from './routes/Holding';
import { Browse } from './routes/Browse';
import { Profile } from './routes/Profile';
import { Welcome } from './routes/Welcome';
import { Loading } from './routes/Loading';
import { HTTP_404 } from './routes/HTTP_404';

test('renders about route', () => {
  render(<About />);
  const linkElement = screen.getByText(/Violet is an open source lightweight media hosting solution/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders holding route', () => {
  render(<Holding heading="Violet is unavailable" subheading="Authentication isn't working right now, please check back later." />);
  const linkElement = screen.getByText(/Authentication isn't working right now, please check back later./i);
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

test('renders loading route', () => {
  render(<Loading />);
  const linkElement = screen.getByText(/Loading Violet/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders error 404 route', () => {
  render(<HTTP_404 />);
  const linkElement = screen.getByText(/404 Not Found/i);
  expect(linkElement).toBeInTheDocument();
});
