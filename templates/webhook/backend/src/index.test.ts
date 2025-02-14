import { describe, it, expect } from '@jest/globals';
import { handler } from './index';
import { APIGatewayProxyEvent } from 'aws-lambda';
// import jest from 'jest';

// Mock the database and AWS SDK interactions
import { jest } from '@jest/globals';

interface MockSecretResponse {
  SecretString: string;
}

jest.mock('pg', () => ({
  Pool: jest.fn(() => ({
    connect: () => Promise.resolve({
      query: () => Promise.resolve({ rows: [{ id: 1, name: 'Test' }] }),
      release: () => {},
    })
  }))
}));

jest.mock('aws-sdk', () => ({
  SecretsManager: jest.fn(() => ({
    getSecretValue: () => ({
      promise: () => Promise.resolve({
        SecretString: JSON.stringify({
          host: 'localhost',
          port: 5432,
          name: 'testdb',
          username: 'testuser',
          password: 'testpassword',
        })
      })
    })
  }))
}));

describe('Dummy Test', () => {
  it('should pass', () => {
    expect(true).toBe(true);
  });
});

describe('handler', () => {
  it('should return a successful response with data', async () => {
    const event: APIGatewayProxyEvent = {
      requestContext: {
        requestId: 'test-request-id',
      },
      // ... other necessary properties ...
    } as any; // Cast to any to simplify the test setup

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
    expect(response.body).toContain('Test');
    expect(response.body).toContain('test-request-id');
  });
});
