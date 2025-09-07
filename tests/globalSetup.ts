import { MongoMemoryServer } from 'mongodb-memory-server';

let mongod: MongoMemoryServer;

export default async function globalSetup() {
  console.log('🚀 Setting up global test environment...');
  
  try {
    // Start in-memory MongoDB instance
    mongod = await MongoMemoryServer.create({
      instance: {
        port: 27018, // Use different port to avoid conflicts
        dbName: 'test_db'
      }
    });
    
    const uri = mongod.getUri();
    process.env.MONGODB_URI = uri;
    
    console.log(`✅ MongoDB Memory Server started at: ${uri}`);
    
    // Store the instance for cleanup
    (global as any).__MONGOD__ = mongod;
    
  } catch (error) {
    console.error('❌ Failed to start MongoDB Memory Server:', error);
    throw error;
  }
}
