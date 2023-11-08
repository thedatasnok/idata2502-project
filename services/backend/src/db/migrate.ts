import { drizzle } from 'drizzle-orm/postgres-js';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';

const migrationClient = postgres({
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT as any,
  database: process.env.POSTGRES_DB,
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
});

export const drizzleMigrate = (client: postgres.Sql) =>
  migrate(drizzle(client), {
    migrationsFolder: './migrations',
  });

drizzleMigrate(migrationClient)
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
