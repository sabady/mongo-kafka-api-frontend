import KafkaService, { KafkaEvent } from '../config/kafka';

export class KafkaProducerService {
  private kafkaService: KafkaService;

  constructor() {
    this.kafkaService = KafkaService.getInstance();
  }

  public async initialize(): Promise<void> {
    await this.kafkaService.connect();
  }

  // User Events
  public async publishUserCreated(userData: any): Promise<void> {
    await this.kafkaService.publishEvent('user-events', {
      type: 'user.created',
      source: 'api-server',
      data: userData,
      metadata: {
        userId: userData._id || userData.id,
        correlationId: userData.correlationId
      }
    });
  }

  public async publishUserUpdated(userData: any): Promise<void> {
    await this.kafkaService.publishEvent('user-events', {
      type: 'user.updated',
      source: 'api-server',
      data: userData,
      metadata: {
        userId: userData._id || userData.id,
        correlationId: userData.correlationId
      }
    });
  }

  public async publishUserDeleted(userData: any): Promise<void> {
    await this.kafkaService.publishEvent('user-events', {
      type: 'user.deleted',
      source: 'api-server',
      data: userData,
      metadata: {
        userId: userData._id || userData.id,
        correlationId: userData.correlationId
      }
    });
  }

  public async publishUserDeactivated(userData: any): Promise<void> {
    await this.kafkaService.publishEvent('user-events', {
      type: 'user.deactivated',
      source: 'api-server',
      data: userData,
      metadata: {
        userId: userData._id || userData.id,
        correlationId: userData.correlationId
      }
    });
  }

  // Product Events
  public async publishProductCreated(productData: any): Promise<void> {
    await this.kafkaService.publishEvent('product-events', {
      type: 'product.created',
      source: 'api-server',
      data: productData,
      metadata: {
        productId: productData._id || productData.id,
        correlationId: productData.correlationId
      }
    });
  }

  public async publishProductUpdated(productData: any): Promise<void> {
    await this.kafkaService.publishEvent('product-events', {
      type: 'product.updated',
      source: 'api-server',
      data: productData,
      metadata: {
        productId: productData._id || productData.id,
        correlationId: productData.correlationId
      }
    });
  }

  public async publishProductDeleted(productData: any): Promise<void> {
    await this.kafkaService.publishEvent('product-events', {
      type: 'product.deleted',
      source: 'api-server',
      data: productData,
      metadata: {
        productId: productData._id || productData.id,
        correlationId: productData.correlationId
      }
    });
  }

  public async publishProductStockUpdated(productData: any): Promise<void> {
    await this.kafkaService.publishEvent('product-events', {
      type: 'product.stock.updated',
      source: 'api-server',
      data: productData,
      metadata: {
        productId: productData._id || productData.id,
        correlationId: productData.correlationId
      }
    });
  }

  // Order Events
  public async publishOrderCreated(orderData: any): Promise<void> {
    await this.kafkaService.publishEvent('order-events', {
      type: 'order.created',
      source: 'api-server',
      data: orderData,
      metadata: {
        orderId: orderData._id || orderData.id,
        userId: orderData.userId,
        correlationId: orderData.correlationId
      }
    });
  }

  public async publishOrderUpdated(orderData: any): Promise<void> {
    await this.kafkaService.publishEvent('order-events', {
      type: 'order.updated',
      source: 'api-server',
      data: orderData,
      metadata: {
        orderId: orderData._id || orderData.id,
        userId: orderData.userId,
        correlationId: orderData.correlationId
      }
    });
  }

  public async publishOrderCancelled(orderData: any): Promise<void> {
    await this.kafkaService.publishEvent('order-events', {
      type: 'order.cancelled',
      source: 'api-server',
      data: orderData,
      metadata: {
        orderId: orderData._id || orderData.id,
        userId: orderData.userId,
        correlationId: orderData.correlationId
      }
    });
  }

  public async publishOrderStatusChanged(orderData: any): Promise<void> {
    await this.kafkaService.publishEvent('order-events', {
      type: 'order.status.changed',
      source: 'api-server',
      data: orderData,
      metadata: {
        orderId: orderData._id || orderData.id,
        userId: orderData.userId,
        correlationId: orderData.correlationId
      }
    });
  }

  // API Events
  public async publishApiRequest(requestData: any): Promise<void> {
    await this.kafkaService.publishEvent('api-events', {
      type: 'api.request',
      source: 'api-server',
      data: requestData,
      metadata: {
        correlationId: requestData.correlationId,
        userId: requestData.userId,
        sessionId: requestData.sessionId
      }
    });
  }

  public async publishApiResponse(responseData: any): Promise<void> {
    await this.kafkaService.publishEvent('api-events', {
      type: 'api.response',
      source: 'api-server',
      data: responseData,
      metadata: {
        correlationId: responseData.correlationId,
        userId: responseData.userId,
        sessionId: responseData.sessionId
      }
    });
  }

  public async publishApiError(errorData: any): Promise<void> {
    await this.kafkaService.publishEvent('api-events', {
      type: 'api.error',
      source: 'api-server',
      data: errorData,
      metadata: {
        correlationId: errorData.correlationId,
        userId: errorData.userId,
        sessionId: errorData.sessionId
      }
    });
  }

  // Audit Logs
  public async publishAuditLog(auditData: any): Promise<void> {
    await this.kafkaService.publishEvent('audit-logs', {
      type: 'audit.log',
      source: 'api-server',
      data: auditData,
      metadata: {
        userId: auditData.userId,
        correlationId: auditData.correlationId,
        sessionId: auditData.sessionId
      }
    });
  }

  public async disconnect(): Promise<void> {
    await this.kafkaService.disconnect();
  }
}

export default KafkaProducerService;
