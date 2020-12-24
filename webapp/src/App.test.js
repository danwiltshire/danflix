import { render, screen } from '@testing-library/react';
import { About } from './views/About';
import { Holding } from './views/Holding';
import { Browse } from './views/Browse';
import { Profile } from './views/Profile';
import { Welcome } from './views/Welcome';
import { Loading } from './views/Loading';
import { BrowserRouter } from 'react-router-dom';
import { Notice } from './views/Notice';

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
  render(
    <BrowserRouter>
      <Browse />
    </BrowserRouter>
  );
  const linkElement = screen.getByText(/Log in/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders profile route', () => {
  render(
    <BrowserRouter>
      <Profile />
    </BrowserRouter>
  );
  const linkElement = screen.getByText(/Log in/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders welcome route', () => {
  render(
    <BrowserRouter>
      <Welcome />
    </BrowserRouter>
  );
  const linkElement = screen.getByText(/Welcome to Violet/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders loading route', () => {
  render(<Loading />);
  const linkElement = screen.getByText(/Loading Violet/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders notice route', () => {
  render(<Notice heading={"A test heading"} subheading={"A test notice subheading"} />);
  const linkElement = screen.getByText(/A test notice subheading/i);
  expect(linkElement).toBeInTheDocument();
});