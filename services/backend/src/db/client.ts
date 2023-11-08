import { Logger } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const queryClient = postgres({
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT as any,
  database: process.env.POSTGRES_DB,
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
});

export const createClient = (
  client: postgres.Sql,
  logger?: boolean | Logger
) => {
  return drizzle(client, { schema, logger });
};

export const db = createClient(queryClient);
