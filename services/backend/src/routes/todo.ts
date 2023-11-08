import { db } from '@/db/client';
import { todo } from '@/db/schema';
import { persistence } from '@/plugins';
import Elysia from 'elysia';
import { getgroups } from 'process';

export const todoRoutes = new Elysia()
  .use(persistence)
  .group('/api/v1/todos', (group) =>
    group
      .get('/', async ({ db }) => {
        const todos = await db.select().from(todo);
        return todos;
      })
      .post('/', async () => {
        return await db.insert(todo).values({ title: 'New todo' });
      })
  );
