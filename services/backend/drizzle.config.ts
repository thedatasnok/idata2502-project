import type { Config } from 'drizzle-kit';

export default {
  out: './migrations',
  schema: './src/db/schema.ts',
  dbCredentials: {
    host: process.env.POSTGRES_HOST!,
    port: process.env.POSTGRES_PORT as any,
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DB!,
  },
} satisfies Config;
