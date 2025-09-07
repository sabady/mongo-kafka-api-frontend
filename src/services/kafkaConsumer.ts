import KafkaService, { KafkaEvent } from '../config/kafka';
import { User, Product, Order } from '../models';
import { asyncHandler } from '../middleware/errorHandler';

export class KafkaConsumerService {
  private kafkaService: KafkaService;
  private isRunning: boolean = false;

  constructor() {
    this.kafkaService = KafkaService.getInstance();
  }

  public async start(): Promise<void> {
    if (this.isRunning) {
      console.log('Kafka consumer service already running');
      return;
    }

    try {
      await this.kafkaService.connect();

      // Start consuming from different topics
      await Promise.all([
        this.startUserEventsConsumer(),
        this.startProductEventsConsumer(),
        this.startOrderEventsConsumer(),
        this.startApiEventsConsumer(),
        this.startAuditLogsConsumer()
      ]);

      this.isRunning = true;
      console.log('🚀 All Kafka consumers started successfully');
    } catch (error) {
      console.error('❌ Failed to start Kafka consumers:', error);
      throw error;
    }
  }

  private async startUserEventsConsumer(): Promise<void> {
    await this.kafkaService.startConsuming(
      {
        groupId: 'api-server-user-events',
        topics: ['user-events'],
        fromBeginning: false,
        autoCommit: true,
        autoCommitInterval: 5000
      },
      this.handleUserEvent.bind(this)
    );
  }

  private async startProductEventsConsumer(): Promise<void> {
    await this.kafkaService.startConsuming(
      {
        groupId: 'api-server-product-events',
        topics: ['product-events'],
        fromBeginning: false,
        autoCommit: true,
        autoCommitInterval: 5000
      },
      this.handleProductEvent.bind(this)
    );
  }

  private async startOrderEventsConsumer(): Promise<void> {
    await this.kafkaService.startConsuming(
      {
        groupId: 'api-server-order-events',
        topics: ['order-events'],
        fromBeginning: false,
        autoCommit: true,
        autoCommitInterval: 5000
      },
      this.handleOrderEvent.bind(this)
    );
  }

  private async startApiEventsConsumer(): Promise<void> {
    await this.kafkaService.startConsuming(
      {
        groupId: 'api-server-api-events',
        topics: ['api-events'],
        fromBeginning: false,
        autoCommit: true,
        autoCommitInterval: 5000
      },
      this.handleApiEvent.bind(this)
    );
  }

  private async startAuditLogsConsumer(): Promise<void> {
    await this.kafkaService.startConsuming(
      {
        groupId: 'api-server-audit-logs',
        topics: ['audit-logs'],
        fromBeginning: false,
        autoCommit: true,
        autoCommitInterval: 5000
      },
      this.handleAuditLog.bind(this)
    );
  }

  private async handleUserEvent(event: KafkaEvent): Promise<void> {
    try {
      console.log(`👤 Processing user event: ${event.type}`, { eventId: event.id });

      switch (event.type) {
        case 'user.created':
          await this.handleUserCreated(event);
          break;
        case 'user.updated':
          await this.handleUserUpdated(event);
          break;
        case 'user.deleted':
          await this.handleUserDeleted(event);
          break;
        case 'user.deactivated':
          await this.handleUserDeactivated(event);
          break;
        default:
          console.log(`⚠️ Unknown user event type: ${event.type}`);
      }
    } catch (error) {
      console.error(`❌ Error handling user event ${event.type}:`, error);
      throw error;
    }
  }

  private async handleProductEvent(event: KafkaEvent): Promise<void> {
    try {
      console.log(`📦 Processing product event: ${event.type}`, { eventId: event.id });

      switch (event.type) {
        case 'product.created':
          await this.handleProductCreated(event);
          break;
        case 'product.updated':
          await this.handleProductUpdated(event);
          break;
        case 'product.deleted':
          await this.handleProductDeleted(event);
          break;
        case 'product.stock.updated':
          await this.handleProductStockUpdated(event);
          break;
        default:
          console.log(`⚠️ Unknown product event type: ${event.type}`);
      }
    } catch (error) {
      console.error(`❌ Error handling product event ${event.type}:`, error);
      throw error;
    }
  }

  private async handleOrderEvent(event: KafkaEvent): Promise<void> {
    try {
      console.log(`🛒 Processing order event: ${event.type}`, { eventId: event.id });

      switch (event.type) {
        case 'order.created':
          await this.handleOrderCreated(event);
          break;
        case 'order.updated':
          await this.handleOrderUpdated(event);
          break;
        case 'order.cancelled':
          await this.handleOrderCancelled(event);
          break;
        case 'order.status.changed':
          await this.handleOrderStatusChanged(event);
          break;
        default:
          console.log(`⚠️ Unknown order event type: ${event.type}`);
      }
    } catch (error) {
      console.error(`❌ Error handling order event ${event.type}:`, error);
      throw error;
    }
  }

  private async handleApiEvent(event: KafkaEvent): Promise<void> {
    try {
      console.log(`🔌 Processing API event: ${event.type}`, { eventId: event.id });

      switch (event.type) {
        case 'api.request':
          await this.handleApiRequest(event);
          break;
        case 'api.response':
          await this.handleApiResponse(event);
          break;
        case 'api.error':
          await this.handleApiError(event);
          break;
        default:
          console.log(`⚠️ Unknown API event type: ${event.type}`);
      }
    } catch (error) {
      console.error(`❌ Error handling API event ${event.type}:`, error);
      throw error;
    }
  }

  private async handleAuditLog(event: KafkaEvent): Promise<void> {
    try {
      console.log(`📋 Processing audit log: ${event.type}`, { eventId: event.id });
      
      // Store audit log in database or send to external audit system
      await this.storeAuditLog(event);
    } catch (error) {
      console.error(`❌ Error handling audit log:`, error);
      throw error;
    }
  }

  // User event handlers
  private async handleUserCreated(event: KafkaEvent): Promise<void> {
    const userData = event.data;
    console.log(`✅ User created event processed: ${userData.email}`);
    // Additional processing logic here
  }

  private async handleUserUpdated(event: KafkaEvent): Promise<void> {
    const userData = event.data;
    console.log(`✅ User updated event processed: ${userData.email}`);
    // Additional processing logic here
  }

  private async handleUserDeleted(event: KafkaEvent): Promise<void> {
    const userData = event.data;
    console.log(`✅ User deleted event processed: ${userData.email}`);
    // Additional processing logic here
  }

  private async handleUserDeactivated(event: KafkaEvent): Promise<void> {
    const userData = event.data;
    console.log(`✅ User deactivated event processed: ${userData.email}`);
    // Additional processing logic here
  }

  // Product event handlers
  private async handleProductCreated(event: KafkaEvent): Promise<void> {
    const productData = event.data;
    console.log(`✅ Product created event processed: ${productData.name}`);
    // Additional processing logic here
  }

  private async handleProductUpdated(event: KafkaEvent): Promise<void> {
    const productData = event.data;
    console.log(`✅ Product updated event processed: ${productData.name}`);
    // Additional processing logic here
  }

  private async handleProductDeleted(event: KafkaEvent): Promise<void> {
    const productData = event.data;
    console.log(`✅ Product deleted event processed: ${productData.name}`);
    // Additional processing logic here
  }

  private async handleProductStockUpdated(event: KafkaEvent): Promise<void> {
    const productData = event.data;
    console.log(`✅ Product stock updated event processed: ${productData.name} - Stock: ${productData.quantity}`);
    // Additional processing logic here
  }

  // Order event handlers
  private async handleOrderCreated(event: KafkaEvent): Promise<void> {
    const orderData = event.data;
    console.log(`✅ Order created event processed: ${orderData.id} - Total: $${orderData.totalAmount}`);
    // Additional processing logic here
  }

  private async handleOrderUpdated(event: KafkaEvent): Promise<void> {
    const orderData = event.data;
    console.log(`✅ Order updated event processed: ${orderData.id}`);
    // Additional processing logic here
  }

  private async handleOrderCancelled(event: KafkaEvent): Promise<void> {
    const orderData = event.data;
    console.log(`✅ Order cancelled event processed: ${orderData.id}`);
    // Additional processing logic here
  }

  private async handleOrderStatusChanged(event: KafkaEvent): Promise<void> {
    const orderData = event.data;
    console.log(`✅ Order status changed event processed: ${orderData.id} - Status: ${orderData.status}`);
    // Additional processing logic here
  }

  // API event handlers
  private async handleApiRequest(event: KafkaEvent): Promise<void> {
    const requestData = event.data;
    console.log(`✅ API request event processed: ${requestData.method} ${requestData.path}`);
    // Additional processing logic here
  }

  private async handleApiResponse(event: KafkaEvent): Promise<void> {
    const responseData = event.data;
    console.log(`✅ API response event processed: ${responseData.statusCode} - ${responseData.path}`);
    // Additional processing logic here
  }

  private async handleApiError(event: KafkaEvent): Promise<void> {
    const errorData = event.data;
    console.log(`✅ API error event processed: ${errorData.statusCode} - ${errorData.path} - ${errorData.error}`);
    // Additional processing logic here
  }

  // Audit log handler
  private async storeAuditLog(event: KafkaEvent): Promise<void> {
    const auditData = event.data;
    console.log(`✅ Audit log stored: ${auditData.action} - ${auditData.resource} - ${auditData.userId || 'system'}`);
    // Store in database or send to external audit system
  }

  public async stop(): Promise<void> {
    if (!this.isRunning) {
      return;
    }

    try {
      await this.kafkaService.disconnect();
      this.isRunning = false;
      console.log('🛑 Kafka consumer service stopped');
    } catch (error) {
      console.error('❌ Error stopping Kafka consumer service:', error);
      throw error;
    }
  }

  public getStatus(): { isRunning: boolean; kafkaConnected: boolean } {
    return {
      isRunning: this.isRunning,
      kafkaConnected: this.kafkaService.getConnectionStatus()
    };
  }
}

export default KafkaConsumerService;
