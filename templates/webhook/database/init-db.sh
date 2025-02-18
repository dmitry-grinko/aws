#!/bin/bash

# Exit on error
set -e

# Check if required environment variables are set
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Required environment variables are not set"
    echo "Please ensure DB_HOST, DB_PORT, DB_NAME, DB_USER, and DB_PASSWORD are set"
    exit 1
fi

# Create the table using psql
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
-- First drop the existing table if it exists
DROP TABLE IF EXISTS emails CASCADE;

-- Create emails table
CREATE TABLE emails (
    email_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    status BOOLEAN NOT NULL DEFAULT FALSE
);

-- Insert sample data
DO $$ 
BEGIN
    -- Only insert if table is empty
    IF NOT EXISTS (SELECT 1 FROM emails LIMIT 1) THEN
        INSERT INTO emails (email, status) VALUES
            ('john@example.com', false),
            ('alice@example.com', true),
            ('bob@example.com', false);
    END IF;
END $$;
EOF

echo "Database initialization completed successfully"