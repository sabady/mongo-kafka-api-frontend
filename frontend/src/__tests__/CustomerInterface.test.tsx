import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import CustomerInterface from '../components/CustomerInterface';

// Mock the services
jest.mock('../services/kafkaProducer', () => ({
  __esModule: true,
  default: jest.fn().mockImplementation(() => ({
    connect: jest.fn().mockResolvedValue(undefined),
    disconnect: jest.fn().mockResolvedValue(undefined),
    publishRandomProductAdded: jest.fn().mockResolvedValue(undefined),
    publishProductCreated: jest.fn().mockResolvedValue(undefined),
    publishAuditLog: jest.fn().mockResolvedValue(undefined),
    publishApiRequest: jest.fn().mockResolvedValue(undefined),
    publishApiResponse: jest.fn().mockResolvedValue(undefined),
    publishApiError: jest.fn().mockResolvedValue(undefined),
    getConnectionStatus: jest.fn().mockReturnValue(true)
  }))
}));

jest.mock('../services/apiService', () => ({
  __esModule: true,
  default: jest.fn().mockImplementation(() => ({
    getProducts: jest.fn().mockResolvedValue({
      success: true,
      data: [
        {
          id: '1',
          name: 'Test Product',
          description: 'A test product',
          price: 99.99,
          category: 'electronics',
          inStock: true,
          quantity: 10
        }
      ]
    })
  }))
}));

jest.mock('../utils/randomProducts', () => ({
  generateRandomProductWithVariations: jest.fn().mockReturnValue({
    id: 'random-1',
    name: 'Random Product',
    description: 'A random product',
    price: 49.99,
    category: 'electronics',
    quantity: 5
  })
}));

describe('CustomerInterface', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders customer interface correctly', () => {
    render(<CustomerInterface />);
    
    expect(screen.getByText('Customer Frontend - Kafka Producer')).toBeInTheDocument();
    expect(screen.getByText('Customer Information')).toBeInTheDocument();
    expect(screen.getByText('Actions')).toBeInTheDocument();
    expect(screen.getByLabelText('Enter your name')).toBeInTheDocument();
  });

  it('shows kafka connection status', () => {
    render(<CustomerInterface />);
    
    expect(screen.getByText('Kafka Connected')).toBeInTheDocument();
  });

  it('requires customer name before adding random item', async () => {
    render(<CustomerInterface />);
    
    const addButton = screen.getByText('Add Random Item to Bought List');
    fireEvent.click(addButton);
    
    await waitFor(() => {
      expect(screen.getByText('Please enter your name first!')).toBeInTheDocument();
    });
  });

  it('adds random item when customer name is provided', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const addButton = screen.getByText('Add Random Item to Bought List');
    fireEvent.click(addButton);
    
    await waitFor(() => {
      expect(screen.getByText('Added "Random Product" to your bought items!')).toBeInTheDocument();
    });
    
    expect(screen.getByText('Bought Items (1)')).toBeInTheDocument();
    expect(screen.getByText('Random Product')).toBeInTheDocument();
  });

  it('requires customer name before getting products from database', async () => {
    render(<CustomerInterface />);
    
    const getProductsButton = screen.getByText('Get Products from MongoDB');
    fireEvent.click(getProductsButton);
    
    await waitFor(() => {
      expect(screen.getByText('Please enter your name first!')).toBeInTheDocument();
    });
  });

  it('fetches products from database when customer name is provided', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const getProductsButton = screen.getByText('Get Products from MongoDB');
    fireEvent.click(getProductsButton);
    
    await waitFor(() => {
      expect(screen.getByText('Retrieved 1 products from database!')).toBeInTheDocument();
    });
    
    expect(screen.getByText('Products from MongoDB (1)')).toBeInTheDocument();
    expect(screen.getByText('Test Product')).toBeInTheDocument();
  });

  it('clears bought items list', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const addButton = screen.getByText('Add Random Item to Bought List');
    fireEvent.click(addButton);
    
    await waitFor(() => {
      expect(screen.getByText('Bought Items (1)')).toBeInTheDocument();
    });
    
    const clearButton = screen.getByText('Clear List');
    fireEvent.click(clearButton);
    
    await waitFor(() => {
      expect(screen.getByText('Cleared bought items list')).toBeInTheDocument();
    });
    
    expect(screen.getByText('Bought Items (0)')).toBeInTheDocument();
  });

  it('clears products from database list', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const getProductsButton = screen.getByText('Get Products from MongoDB');
    fireEvent.click(getProductsButton);
    
    await waitFor(() => {
      expect(screen.getByText('Products from MongoDB (1)')).toBeInTheDocument();
    });
    
    const clearButton = screen.getByText('Clear List');
    fireEvent.click(clearButton);
    
    await waitFor(() => {
      expect(screen.getByText('Cleared products from database list')).toBeInTheDocument();
    });
    
    expect(screen.getByText('Products from MongoDB (0)')).toBeInTheDocument();
  });

  it('shows loading state when adding random item', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const addButton = screen.getByText('Add Random Item to Bought List');
    fireEvent.click(addButton);
    
    expect(screen.getByText('Adding...')).toBeInTheDocument();
  });

  it('shows loading state when getting products', async () => {
    render(<CustomerInterface />);
    
    const nameInput = screen.getByLabelText('Enter your name');
    fireEvent.change(nameInput, { target: { value: 'John Doe' } });
    
    const getProductsButton = screen.getByText('Get Products from MongoDB');
    fireEvent.click(getProductsButton);
    
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
