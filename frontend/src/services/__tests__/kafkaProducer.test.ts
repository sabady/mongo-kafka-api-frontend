import KafkaProducerService from '../kafkaProducer';

// Mock kafkajs
jest.mock('kafkajs', () => ({
  Kafka: jest.fn().mockImplementation(() => ({
    producer: jest.fn().mockReturnValue({
      connect: jest.fn().mockResolvedValue(undefined),
      disconnect: jest.fn().mockResolvedValue(undefined),
      send: jest.fn().mockResolvedValue(undefined)
    })
  }))
}));

describe('KafkaProducerService', () => {
  let kafkaProducer: KafkaProducerService;

  beforeEach(() => {
    kafkaProducer = new KafkaProducerService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('connect', () => {
    it('should connect to Kafka successfully', async () => {
      await expect(kafkaProducer.connect()).resolves.toBeUndefined();
    });

    it('should not connect if already connected', async () => {
      await kafkaProducer.connect();
      await kafkaProducer.connect(); // Should not throw
    });
  });

  describe('publishEvent', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish event successfully', async () => {
      const event = {
        type: 'test.event',
        source: 'test',
        data: { test: 'data' }
      };

      await expect(kafkaProducer.publishEvent('test-topic', event)).resolves.toBeUndefined();
    });

    it('should throw error if not connected', async () => {
      const newProducer = new KafkaProducerService();
      const event = {
        type: 'test.event',
        source: 'test',
        data: { test: 'data' }
      };

      await expect(newProducer.publishEvent('test-topic', event)).rejects.toThrow('Producer not connected');
    });
  });

  describe('publishCustomerCreated', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish customer created event', async () => {
      const customerData = { id: '1', name: 'John Doe', email: 'john@example.com' };
      
      await expect(kafkaProducer.publishCustomerCreated(customerData)).resolves.toBeUndefined();
    });
  });

  describe('publishProductCreated', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish product created event', async () => {
      const productData = { id: '1', name: 'Test Product', price: 99.99 };
      
      await expect(kafkaProducer.publishProductCreated(productData)).resolves.toBeUndefined();
    });
  });

  describe('publishRandomProductAdded', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish random product added event', async () => {
      const productData = { id: '1', name: 'Random Product', price: 49.99 };
      const customerName = 'John Doe';
      
      await expect(kafkaProducer.publishRandomProductAdded(productData, customerName)).resolves.toBeUndefined();
    });
  });

  describe('publishApiRequest', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish API request event', async () => {
      const requestData = { method: 'GET', path: '/api/users', customerName: 'John Doe' };
      
      await expect(kafkaProducer.publishApiRequest(requestData)).resolves.toBeUndefined();
    });
  });

  describe('publishApiResponse', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish API response event', async () => {
      const responseData = { method: 'GET', path: '/api/users', statusCode: 200, customerName: 'John Doe' };
      
      await expect(kafkaProducer.publishApiResponse(responseData)).resolves.toBeUndefined();
    });
  });

  describe('publishApiError', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish API error event', async () => {
      const errorData = { method: 'GET', path: '/api/users', statusCode: 500, error: 'Internal Server Error', customerName: 'John Doe' };
      
      await expect(kafkaProducer.publishApiError(errorData)).resolves.toBeUndefined();
    });
  });

  describe('publishAuditLog', () => {
    beforeEach(async () => {
      await kafkaProducer.connect();
    });

    it('should publish audit log event', async () => {
      const auditData = { action: 'user.login', resource: 'user', customerName: 'John Doe' };
      
      await expect(kafkaProducer.publishAuditLog(auditData)).resolves.toBeUndefined();
    });
  });

  describe('disconnect', () => {
    it('should disconnect from Kafka successfully', async () => {
      await kafkaProducer.connect();
      await expect(kafkaProducer.disconnect()).resolves.toBeUndefined();
    });
  });

  describe('getConnectionStatus', () => {
    it('should return connection status', () => {
      expect(typeof kafkaProducer.getConnectionStatus()).toBe('boolean');
    });
  });
});
