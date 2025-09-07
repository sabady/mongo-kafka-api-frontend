import { register, Counter, Histogram, Gauge, collectDefaultMetrics } from 'prom-client';

// Enable default metrics collection
collectDefaultMetrics();

// HTTP request metrics
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

export const httpRequestsPerSecond = new Gauge({
  name: 'http_requests_per_second',
  help: 'HTTP requests per second',
  labelNames: ['method', 'route']
});

// Database metrics
export const databaseConnections = new Gauge({
  name: 'mongodb_connections',
  help: 'Number of active MongoDB connections',
  labelNames: ['state']
});

export const databaseOperations = new Counter({
  name: 'mongodb_operations_total',
  help: 'Total number of MongoDB operations',
  labelNames: ['operation', 'collection']
});

export const databaseOpsPerSecond = new Gauge({
  name: 'mongodb_ops_per_second',
  help: 'MongoDB operations per second',
  labelNames: ['operation', 'collection']
});

// Kafka metrics
export const kafkaMessagesProduced = new Counter({
  name: 'kafka_messages_produced_total',
  help: 'Total number of Kafka messages produced',
  labelNames: ['topic', 'partition']
});

export const kafkaMessagesConsumed = new Counter({
  name: 'kafka_messages_consumed_total',
  help: 'Total number of Kafka messages consumed',
  labelNames: ['topic', 'partition', 'consumer_group']
});

export const kafkaConsumerLag = new Gauge({
  name: 'kafka_consumer_lag_sum',
  help: 'Kafka consumer lag',
  labelNames: ['topic', 'partition', 'consumer_group']
});

export const kafkaMessagesPerSecond = new Gauge({
  name: 'kafka_messages_per_second',
  help: 'Kafka messages per second',
  labelNames: ['topic', 'type']
});

// Business metrics
export const activeUserSessions = new Gauge({
  name: 'active_user_sessions',
  help: 'Number of active user sessions',
  labelNames: ['customer_name']
});

export const productsCreated = new Counter({
  name: 'products_created_total',
  help: 'Total number of products created',
  labelNames: ['category', 'source']
});

export const ordersCreated = new Counter({
  name: 'orders_created_total',
  help: 'Total number of orders created',
  labelNames: ['status', 'customer_name']
});

// System metrics
export const memoryUsage = new Gauge({
  name: 'nodejs_memory_usage_bytes',
  help: 'Node.js memory usage in bytes',
  labelNames: ['type']
});

export const cpuUsage = new Gauge({
  name: 'nodejs_cpu_usage_percent',
  help: 'Node.js CPU usage percentage'
});

export const eventProcessingDuration = new Histogram({
  name: 'event_processing_duration_seconds',
  help: 'Duration of event processing in seconds',
  labelNames: ['event_type', 'topic'],
  buckets: [0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5]
});

// Initialize metrics
export function createPrometheusMetrics() {
  // Update memory usage periodically
  setInterval(() => {
    const memUsage = process.memoryUsage();
    memoryUsage.set({ type: 'rss' }, memUsage.rss);
    memoryUsage.set({ type: 'heapTotal' }, memUsage.heapTotal);
    memoryUsage.set({ type: 'heapUsed' }, memUsage.heapUsed);
    memoryUsage.set({ type: 'external' }, memUsage.external);
  }, 5000);

  // Update CPU usage periodically
  setInterval(() => {
    const cpuUsage = process.cpuUsage();
    const totalCpuUsage = (cpuUsage.user + cpuUsage.system) / 1000000; // Convert to seconds
    cpuUsage.set(totalCpuUsage);
  }, 5000);

  return register;
}

// Middleware to collect HTTP metrics
export function metricsMiddleware(req: any, res: any, next: any) {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode.toString()
    };

    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
  });

  next();
}

// Utility functions to update metrics
export function incrementHttpRequests(method: string, route: string, statusCode: number) {
  httpRequestTotal.inc({
    method,
    route,
    status_code: statusCode.toString()
  });
}

export function updateHttpRequestsPerSecond(method: string, route: string, count: number) {
  httpRequestsPerSecond.set({ method, route }, count);
}

export function updateDatabaseConnections(connections: number, state: string = 'active') {
  databaseConnections.set({ state }, connections);
}

export function incrementDatabaseOperations(operation: string, collection: string) {
  databaseOperations.inc({ operation, collection });
}

export function updateDatabaseOpsPerSecond(operation: string, collection: string, opsPerSecond: number) {
  databaseOpsPerSecond.set({ operation, collection }, opsPerSecond);
}

export function incrementKafkaMessagesProduced(topic: string, partition: number = 0) {
  kafkaMessagesProduced.inc({ topic, partition: partition.toString() });
}

export function incrementKafkaMessagesConsumed(topic: string, partition: number = 0, consumerGroup: string = 'default') {
  kafkaMessagesConsumed.inc({ topic, partition: partition.toString(), consumer_group: consumerGroup });
}

export function updateKafkaConsumerLag(topic: string, partition: number = 0, consumerGroup: string = 'default', lag: number) {
  kafkaConsumerLag.set({ topic, partition: partition.toString(), consumer_group: consumerGroup }, lag);
}

export function updateKafkaMessagesPerSecond(topic: string, type: string, messagesPerSecond: number) {
  kafkaMessagesPerSecond.set({ topic, type }, messagesPerSecond);
}

export function updateActiveUserSessions(customerName: string, count: number) {
  activeUserSessions.set({ customer_name: customerName }, count);
}

export function incrementProductsCreated(category: string, source: string) {
  productsCreated.inc({ category, source });
}

export function incrementOrdersCreated(status: string, customerName: string) {
  ordersCreated.inc({ status, customer_name: customerName });
}

export function recordEventProcessingDuration(eventType: string, topic: string, duration: number) {
  eventProcessingDuration.observe({ event_type: eventType, topic }, duration);
}
