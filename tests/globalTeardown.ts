export default async function globalTeardown() {
  console.log('🧹 Cleaning up global test environment...');
  
  try {
    // Stop MongoDB Memory Server
    const mongod = (global as any).__MONGOD__;
    if (mongod) {
      await mongod.stop();
      console.log('✅ MongoDB Memory Server stopped');
    }
    
    console.log('✅ Global test environment cleaned up');
  } catch (error) {
    console.error('❌ Error during global teardown:', error);
    throw error;
  }
}
