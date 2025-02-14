import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Pool, QueryResult } from 'pg';
import { SecretsManager } from 'aws-sdk';

// Initialize the connection pool outside the handler to reuse connections
const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false // Required for AWS RDS SSL connections
  }
});

const secretsManager = new SecretsManager();

// Common response headers
const defaultHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Credentials': true,
};

interface ResponseBody {
  data?: any;
  message?: string;
  error?: string;
  timestamp?: string;
  requestId: string;
}

const createResponse = (
  statusCode: number,
  body: ResponseBody
): APIGatewayProxyResult => ({
  statusCode,
  headers: defaultHeaders,
  body: JSON.stringify(body),
});

const fetchDataFromDatabase = async (): Promise<QueryResult> => {
  const client = await pool.connect();
  try {
    // Replace 'your_table_name' with your actual table name
    return await client.query('SELECT * FROM your_table_name');
  } finally {
    client.release();
  }
};

const getRequestId = (event: APIGatewayProxyEvent): string => {
  return event.requestContext?.requestId || 'unknown';
};

async function getDatabaseCredentials() {
  const secretValue = await secretsManager.getSecretValue({
    SecretId: process.env.SECRETS_ARN!
  }).promise();
  
  return JSON.parse(secretValue.SecretString!);
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const result = await fetchDataFromDatabase();
    
    return createResponse(200, {
      data: result.rows,
      timestamp: new Date().toISOString(),
      requestId: getRequestId(event)
    });

  } catch (error) {
    console.error(
      'Error processing request:',
      error instanceof Error ? error.message : String(error)
    );
    
    return createResponse(500, {
      message: 'Internal server error',
      error: error instanceof Error ? error.message : 'Unknown error',
      requestId: getRequestId(event)
    });
  }
};
