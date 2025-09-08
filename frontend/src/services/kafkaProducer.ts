import { Kafka } from 'kafkajs';
import { v4 as uuidv4 } from 'uuid';
import { KafkaEvent, RandomProduct } from '../types';

class KafkaProducerService {
  private kafka: Kafka;
  private producer: any = null;
  private isConnected: boolean = false;

  constructor() {
    this.kafka = new Kafka({
      clientId: 'customer-frontend',
      brokers: [process.env.REACT_APP_KAFKA_BROKERS || 'localhost:9092'],
      retry: {
        initialRetryTime: 100,
        retries: 8
      },
      connectionTimeout: 3000,
      requestTimeout: 25000,
    });
  }

  public async connect(): Promise<void> {
    if (this.isConnected) {
      console.log('Kafka producer already connected');
      return;
    }

    try {
      this.producer = this.kafka.producer({
        maxInFlightRequests: 1,
        idempotent: true,
        transactionTimeout: 30000,
      });

      await this.producer.connect();
      this.isConnected = true;
      console.log('✅ Kafka producer connected successfully');
    } catch (error) {
      console.error('❌ Failed to connect to Kafka:', error);
      throw error;
    }
  }

  public async publishEvent(topic: string, event: Omit<KafkaEvent, 'id' | 'timestamp'>): Promise<void> {
    if (!this.producer) {
      throw new Error('Producer not connected');
    }

    const kafkaEvent: KafkaEvent = {
      id: uuidv4(),
      timestamp: new Date(),
      ...event
    };

    try {
      await this.producer.send({
        topic,
        messages: [{
          key: kafkaEvent.id,
          value: JSON.stringify(kafkaEvent),
          headers: {
            eventType: kafkaEvent.type,
            eventId: kafkaEvent.id,
            timestamp: kafkaEvent.timestamp.toISOString(),
            source: kafkaEvent.source
          }
        }]
      });

      console.log(`📤 Published event to topic ${topic}:`, {
        eventId: kafkaEvent.id,
        eventType: kafkaEvent.type
      });
    } catch (error) {
      console.error(`❌ Failed to publish event to topic ${topic}:`, error);
      throw error;
    }
  }

  // Customer Events
  public async publishCustomerCreated(customerData: any): Promise<void> {
    await this.publishEvent('user-events', {
      type: 'user.created',
      source: 'customer-frontend',
      data: customerData,
      metadata: {
        userId: customerData.id,
        correlationId: customerData.correlationId
      }
    });
  }

  public async publishCustomerUpdated(customerData: any): Promise<void> {
    await this.publishEvent('user-events', {
      type: 'user.updated',
      source: 'customer-frontend',
      data: customerData,
      metadata: {
        userId: customerData.id,
        correlationId: customerData.correlationId
      }
    });
  }

  // Product Events
  public async publishProductCreated(productData: any): Promise<void> {
    await this.publishEvent('product-events', {
      type: 'product.created',
      source: 'customer-frontend',
      data: productData,
      metadata: {
        productId: productData.id,
        correlationId: productData.correlationId
      }
    });
  }

  public async publishRandomProductAdded(productData: any, customerName: string): Promise<void> {
    await this.publishEvent('product-events', {
      type: 'product.random.added',
      source: 'customer-frontend',
      data: {
        ...productData,
        addedBy: customerName,
        addedAt: new Date().toISOString()
      },
      metadata: {
        productId: productData.id,
        correlationId: productData.correlationId,
        customerName
      }
    });
  }

  // Order Events
  public async publishOrderCreated(orderData: any): Promise<void> {
    await this.publishEvent('order-events', {
      type: 'order.created',
      source: 'customer-frontend',
      data: orderData,
      metadata: {
        orderId: orderData.id,
        userId: orderData.userId,
        correlationId: orderData.correlationId
      }
    });
  }

  public async publishItemAddedToCart(itemData: any, customerName: string): Promise<void> {
    await this.publishEvent('order-events', {
      type: 'order.item.added',
      source: 'customer-frontend',
      data: {
        ...itemData,
        customerName,
        addedAt: new Date().toISOString()
      },
      metadata: {
        correlationId: itemData.correlationId,
        customerName
      }
    });
  }

  // API Events
  public async publishApiRequest(requestData: any): Promise<void> {
    await this.publishEvent('api-events', {
      type: 'api.request',
      source: 'customer-frontend',
      data: requestData,
      metadata: {
        correlationId: requestData.correlationId,
        customerName: requestData.customerName
      }
    });
  }

  public async publishApiResponse(responseData: any): Promise<void> {
    await this.publishEvent('api-events', {
      type: 'api.response',
      source: 'customer-frontend',
      data: responseData,
      metadata: {
        correlationId: responseData.correlationId,
        customerName: responseData.customerName
      }
    });
  }

  public async publishApiError(errorData: any): Promise<void> {
    await this.publishEvent('api-events', {
      type: 'api.error',
      source: 'customer-frontend',
      data: errorData,
      metadata: {
        correlationId: errorData.correlationId,
        customerName: errorData.customerName
      }
    });
  }

  // Audit Logs
  public async publishAuditLog(auditData: any): Promise<void> {
    await this.publishEvent('audit-logs', {
      type: 'audit.log',
      source: 'customer-frontend',
      data: auditData,
      metadata: {
        correlationId: auditData.correlationId,
        customerName: auditData.customerName
      }
    });
  }

  public async disconnect(): Promise<void> {
    try {
      if (this.producer) {
        await this.producer.disconnect();
        console.log('🔌 Kafka producer disconnected');
      }
      this.isConnected = false;
    } catch (error) {
      console.error('❌ Error disconnecting from Kafka:', error);
      throw error;
    }
  }

  public getConnectionStatus(): boolean {
    return this.isConnected;
  }
}

export default KafkaProducerService;
