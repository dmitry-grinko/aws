import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Pool, QueryResult } from 'pg';
import { SecretsManager } from 'aws-sdk';

const secretsManager = new SecretsManager();

// Fetch database credentials once and initialize the pool
let pool: Pool;

async function initializePool(): Promise<void> {
  const dbCredentials = await getDatabaseCredentials();
  pool = new Pool({
    host: dbCredentials.host,
    port: dbCredentials.port,
    database: dbCredentials.name,
    user: dbCredentials.username,
    password: dbCredentials.password,
    ssl: {
      rejectUnauthorized: false // Required for AWS RDS SSL connections
    }
  });
}

// Common response headers
const defaultHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Credentials': true,
};

interface ResponseBody {
  data?: Record<string, unknown>;
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
    return await client.query('SELECT * FROM your_table_name');
  } finally {
    client.release();
  }
};

const getRequestId = (event: APIGatewayProxyEvent): string => {
  return event.requestContext?.requestId || 'unknown';
};

async function getDatabaseCredentials(): Promise<{
  host: string;
  port: number;
  name: string;
  username: string;
  password: string;
}> {
  const secretValue = await secretsManager.getSecretValue({
    SecretId: process.env.SECRETS_ARN!
  }).promise();
  
  return JSON.parse(secretValue.SecretString!);
}

function handleError(error: unknown, event: APIGatewayProxyEvent): APIGatewayProxyResult {
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

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Initialize the pool if it hasn't been initialized yet
    if (!pool) {
      await initializePool();
    }

    const result = await fetchDataFromDatabase();

    console.log('Result:', result.rows);

    return createResponse(200, {
      data: Object.fromEntries(result.rows.map((row, i) => [i, row])), // Convert rows to an object
      timestamp: new Date().toISOString(), 
      requestId: getRequestId(event)
    });

  } catch (error) {
    return handleError(error, event);
  }
};
