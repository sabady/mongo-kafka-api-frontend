import { Kafka, Consumer, Producer, EachMessagePayload, KafkaMessage } from 'kafkajs';
import { v4 as uuidv4 } from 'uuid';
import dotenv from 'dotenv';

dotenv.config();

export interface KafkaEvent {
  id: string;
  type: string;
  timestamp: Date;
  source: string;
  data: any;
  metadata?: {
    correlationId?: string;
    userId?: string;
    sessionId?: string;
    [key: string]: any;
  };
}

export interface KafkaConsumerConfig {
  groupId: string;
  topics: string[];
  fromBeginning?: boolean;
  autoCommit?: boolean;
  autoCommitInterval?: number;
  maxBytesPerPartition?: number;
  sessionTimeout?: number;
  heartbeatInterval?: number;
}

class KafkaService {
  private static instance: KafkaService;
  private kafka: Kafka;
  private consumer: Consumer | null = null;
  private producer: Producer | null = null;
  private isConnected: boolean = false;
  private constructor() {
    const kafkaConfig = {
      clientId: process.env['KAFKA_CLIENT_ID'] || 'api-server',
      brokers: [process.env['KAFKA_BROKERS'] || 'kafka-service:9092'],
      retry: {
        initialRetryTime: 100,
        retries: 8
      },
      connectionTimeout: 3000,
      requestTimeout: 25000,
    };

    this.kafka = new Kafka(kafkaConfig);
  }

  public static getInstance(): KafkaService {
    if (!KafkaService.instance) {
      KafkaService.instance = new KafkaService();
    }
    return KafkaService.instance;
  }

  public async connect(): Promise<void> {
    if (this.isConnected) {
      console.log('Kafka already connected');
      return;
    }

    try {
      // Create producer
      this.producer = this.kafka.producer({
        maxInFlightRequests: 1,
        idempotent: true,
        transactionTimeout: 30000,
      });

      await this.producer.connect();
      console.log('✅ Kafka producer connected successfully');

      this.isConnected = true;
      console.log('✅ Kafka service connected successfully');
    } catch (error) {
      console.error('❌ Failed to connect to Kafka:', error);
      throw error;
    }
  }

  public async createConsumer(config: KafkaConsumerConfig): Promise<Consumer> {
    if (!this.isConnected) {
      await this.connect();
    }

    const consumer = this.kafka.consumer({
      groupId: config.groupId,
      sessionTimeout: config.sessionTimeout || 30000,
      heartbeatInterval: config.heartbeatInterval || 3000,
      maxBytesPerPartition: config.maxBytesPerPartition || 1048576,
      retry: {
        initialRetryTime: 100,
        retries: 8
      }
    });

    await consumer.connect();
    console.log(`✅ Kafka consumer connected for group: ${config.groupId}`);

    // Subscribe to topics
    for (const topic of config.topics) {
      await consumer.subscribe({
        topic,
        fromBeginning: config.fromBeginning || false
      });
      console.log(`📡 Subscribed to topic: ${topic}`);
    }

    return consumer;
  }

  public async startConsuming(
    config: KafkaConsumerConfig,
    messageHandler: (event: KafkaEvent) => Promise<void>
  ): Promise<void> {
    try {
      const consumer = await this.createConsumer(config);

      await consumer.run({
        autoCommit: config.autoCommit !== false,
        autoCommitInterval: config.autoCommitInterval || 5000,
        eachMessage: async (payload: EachMessagePayload) => {
          try {
            const event = this.parseMessage(payload.message);
            console.log(`📨 Received message from topic ${payload.topic}:`, {
              partition: payload.partition,
              offset: payload.message.offset,
              eventType: event.type,
              eventId: event.id
            });

            await messageHandler(event);
          } catch (error) {
            console.error(`❌ Error processing message from topic ${payload.topic}:`, error);
            // In production, you might want to send to a dead letter queue
          }
        }
      });

      console.log(`🚀 Started consuming from topics: ${config.topics.join(', ')}`);
    } catch (error) {
      console.error('❌ Failed to start consuming:', error);
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

  private parseMessage(message: KafkaMessage): KafkaEvent {
    try {
      const value = message.value?.toString();
      if (!value) {
        throw new Error('Message value is empty');
      }

      const event = JSON.parse(value) as KafkaEvent;
      
      // Validate required fields
      if (!event.id || !event.type || !event.timestamp || !event.source || !event.data) {
        throw new Error('Invalid event format: missing required fields');
      }

      return event;
    } catch (error) {
      console.error('❌ Failed to parse Kafka message:', error);
      throw new Error(`Invalid message format: ${error}`);
    }
  }

  public async disconnect(): Promise<void> {
    try {
      if (this.consumer) {
        await this.consumer.disconnect();
        console.log('🔌 Kafka consumer disconnected');
      }

      if (this.producer) {
        await this.producer.disconnect();
        console.log('🔌 Kafka producer disconnected');
      }

      this.isConnected = false;
      console.log('🔌 Kafka service disconnected');
    } catch (error) {
      console.error('❌ Error disconnecting from Kafka:', error);
      throw error;
    }
  }

  public getConnectionStatus(): boolean {
    return this.isConnected;
  }

  public getConnectionInfo() {
    return {
      isConnected: this.isConnected,
      clientId: (this.kafka as any).options?.clientId || 'unknown',
      brokers: (this.kafka as any).options?.brokers || []
    };
  }
}

export default KafkaService;
