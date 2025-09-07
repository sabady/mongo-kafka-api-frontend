import mongoose from 'mongoose';
import { User } from '../../../src/models/User';

describe('User Model', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI!);
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  beforeEach(async () => {
    await User.deleteMany({});
  });

  describe('User Creation', () => {
    it('should create a user with valid data', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 30
      };

      const user = new User(userData);
      const savedUser = await user.save();

      expect(savedUser._id).toBeDefined();
      expect(savedUser.name).toBe(userData.name);
      expect(savedUser.email).toBe(userData.email);
      expect(savedUser.age).toBe(userData.age);
      expect(savedUser.isActive).toBe(true);
      expect(savedUser.createdAt).toBeValidDate();
      expect(savedUser.updatedAt).toBeValidDate();
    });

    it('should create a user with minimal required data', async () => {
      const userData = {
        name: 'Jane Doe',
        email: 'jane@example.com'
      };

      const user = new User(userData);
      const savedUser = await user.save();

      expect(savedUser._id).toBeDefined();
      expect(savedUser.name).toBe(userData.name);
      expect(savedUser.email).toBe(userData.email);
      expect(savedUser.isActive).toBe(true);
    });

    it('should not create a user without required fields', async () => {
      const user = new User({});

      await expect(user.save()).rejects.toThrow();
    });

    it('should not create a user with invalid email', async () => {
      const userData = {
        name: 'John Doe',
        email: 'invalid-email'
      };

      const user = new User(userData);
      await expect(user.save()).rejects.toThrow();
    });

    it('should not create a user with duplicate email', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };

      const user1 = new User(userData);
      await user1.save();

      const user2 = new User(userData);
      await expect(user2.save()).rejects.toThrow();
    });
  });

  describe('User Validation', () => {
    it('should validate name length', async () => {
      const userData = {
        name: 'A', // Too short
        email: 'test@example.com'
      };

      const user = new User(userData);
      await expect(user.save()).rejects.toThrow();
    });

    it('should validate age range', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        age: -5 // Invalid age
      };

      const user = new User(userData);
      await expect(user.save()).rejects.toThrow();
    });

    it('should accept valid age range', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 25
      };

      const user = new User(userData);
      const savedUser = await user.save();

      expect(savedUser.age).toBe(25);
    });
  });

  describe('User Methods', () => {
    it('should deactivate user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };

      const user = new User(userData);
      await user.save();

      await user.deactivate();
      expect(user.isActive).toBe(false);
    });

    it('should return full info virtual', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };

      const user = new User(userData);
      await user.save();

      expect(user.fullInfo).toContain('John Doe');
      expect(user.fullInfo).toContain('john@example.com');
      expect(user.fullInfo).toContain('Active');
    });
  });

  describe('User Statics', () => {
    it('should find active users', async () => {
      const user1 = new User({ name: 'John Doe', email: 'john@example.com' });
      const user2 = new User({ name: 'Jane Doe', email: 'jane@example.com', isActive: false });
      
      await user1.save();
      await user2.save();

      const activeUsers = await User.findActiveUsers();
      expect(activeUsers).toHaveLength(1);
      expect(activeUsers[0].email).toBe('john@example.com');
    });
  });
});
