import request from 'supertest';
import app from '../../src/server';

describe('Health Check E2E Tests', () => {
  describe('GET /health', () => {
    it('should return basic health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.status).toBe('ok');
      expect(response.body.timestamp).toBeDefined();
      expect(response.body.database).toBeDefined();
      expect(response.body.kafka).toBeDefined();
    });

    it('should include database connection status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.database.connected).toBeDefined();
      expect(response.body.database.readyState).toBeDefined();
    });

    it('should include kafka connection status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.kafka.connected).toBeDefined();
      expect(response.body.kafka.consumerRunning).toBeDefined();
    });
  });

  describe('GET /api/health', () => {
    it('should return detailed health status', async () => {
      const response = await request(app)
        .get('/api/health')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Health check successful');
      expect(response.body.data).toBeDefined();
      expect(response.body.data.status).toBeDefined();
      expect(response.body.data.timestamp).toBeDefined();
      expect(response.body.data.uptime).toBeDefined();
      expect(response.body.data.memory).toBeDefined();
      expect(response.body.data.database).toBeDefined();
    });
  });

  describe('GET /api/health/detailed', () => {
    it('should return comprehensive health status', async () => {
      const response = await request(app)
        .get('/api/health/detailed')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
      expect(response.body.data.status).toBeDefined();
      expect(response.body.data.timestamp).toBeDefined();
      expect(response.body.data.uptime).toBeDefined();
      expect(response.body.data.memory).toBeDefined();
      expect(response.body.data.cpu).toBeDefined();
      expect(response.body.data.database).toBeDefined();
      expect(response.body.data.environment).toBeDefined();
      expect(response.body.data.version).toBeDefined();
      expect(response.body.data.nodeVersion).toBeDefined();
      expect(response.body.data.platform).toBeDefined();
      expect(response.body.data.arch).toBeDefined();
    });

    it('should include database test results', async () => {
      const response = await request(app)
        .get('/api/health/detailed')
        .expect(200);

      expect(response.body.data.database.test).toBeDefined();
      expect(response.body.data.database.test.status).toBeDefined();
    });
  });

  describe('GET /metrics', () => {
    it('should return Prometheus metrics', async () => {
      const response = await request(app)
        .get('/metrics')
        .expect(200);

      expect(response.headers['content-type']).toContain('text/plain');
      expect(response.text).toContain('# HELP');
      expect(response.text).toContain('# TYPE');
    });
  });

  describe('GET /', () => {
    it('should return API information', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(response.body.message).toBe('MongoDB API Server');
      expect(response.body.version).toBeDefined();
      expect(response.body.status).toBe('running');
      expect(response.body.timestamp).toBeDefined();
      expect(response.body.endpoints).toBeDefined();
    });
  });

  describe('GET /api', () => {
    it('should return API documentation', async () => {
      const response = await request(app)
        .get('/api')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('MongoDB API Server');
      expect(response.body.version).toBeDefined();
      expect(response.body.endpoints).toBeDefined();
      expect(response.body.documentation).toBeDefined();
    });
  });
});
