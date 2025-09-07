import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../App';

// Mock the CustomerInterface component
jest.mock('../components/CustomerInterface', () => {
  return function MockCustomerInterface() {
    return <div data-testid="customer-interface">Customer Interface</div>;
  };
});

describe('App', () => {
  it('renders without crashing', () => {
    render(<App />);
    expect(screen.getByTestId('customer-interface')).toBeInTheDocument();
  });

  it('renders the main title', () => {
    render(<App />);
    expect(screen.getByText('Customer Frontend - Kafka Producer')).toBeInTheDocument();
  });
});
