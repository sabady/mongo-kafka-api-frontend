import axios, { AxiosResponse } from 'axios';
import { ApiResponse, Product, Customer } from '../types';

class ApiService {
  private baseURL: string;

  constructor() {
    this.baseURL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';
  }

  // Customer/User operations
  public async createCustomer(customerData: Partial<Customer>): Promise<ApiResponse<Customer>> {
    try {
      const response: AxiosResponse<ApiResponse<Customer>> = await axios.post(
        `${this.baseURL}/users`,
        customerData
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getCustomer(customerId: string): Promise<ApiResponse<Customer>> {
    try {
      const response: AxiosResponse<ApiResponse<Customer>> = await axios.get(
        `${this.baseURL}/users/${customerId}`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getCustomers(): Promise<ApiResponse<Customer[]>> {
    try {
      const response: AxiosResponse<ApiResponse<Customer[]>> = await axios.get(
        `${this.baseURL}/users`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Product operations
  public async createProduct(productData: Partial<Product>): Promise<ApiResponse<Product>> {
    try {
      const response: AxiosResponse<ApiResponse<Product>> = await axios.post(
        `${this.baseURL}/products`,
        productData
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getProducts(): Promise<ApiResponse<Product[]>> {
    try {
      const response: AxiosResponse<ApiResponse<Product[]>> = await axios.get(
        `${this.baseURL}/products`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getProduct(productId: string): Promise<ApiResponse<Product>> {
    try {
      const response: AxiosResponse<ApiResponse<Product>> = await axios.get(
        `${this.baseURL}/products/${productId}`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getProductsByCategory(category: string): Promise<ApiResponse<Product[]>> {
    try {
      const response: AxiosResponse<ApiResponse<Product[]>> = await axios.get(
        `${this.baseURL}/products/category/${category}`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  public async getAvailableProducts(): Promise<ApiResponse<Product[]>> {
    try {
      const response: AxiosResponse<ApiResponse<Product[]>> = await axios.get(
        `${this.baseURL}/products/available`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  // Health check
  public async getHealth(): Promise<ApiResponse<any>> {
    try {
      const response: AxiosResponse<ApiResponse<any>> = await axios.get(
        `${this.baseURL.replace('/api', '')}/health`
      );
      return response.data;
    } catch (error: any) {
      throw this.handleError(error);
    }
  }

  private handleError(error: any): Error {
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.message || error.response.data?.error || 'Server error';
      return new Error(`API Error: ${message}`);
    } else if (error.request) {
      // Request was made but no response received
      return new Error('Network Error: Unable to connect to the API server');
    } else {
      // Something else happened
      return new Error(`Error: ${error.message}`);
    }
  }
}

export default ApiService;
