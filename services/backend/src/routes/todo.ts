import { db } from '@/db/client';
import { todo } from '@/db/schema';
import { persistence } from '@/plugins';
import { eq } from 'drizzle-orm';
import Elysia, { NotFoundError, t } from 'elysia';

const createTodoSchema = t.Object({
  title: t.String(),
  description: t.Nullable(t.String()),
});

const updateTodoSchema = t.Composite([
  createTodoSchema,
  t.Object({
    completed: t.Boolean(),
  }),
]);

const todoIdParamSchema = t.Object({ id: t.String() });

export const todoRoutes = new Elysia()
  .use(persistence)
  .group('/api/v1/todos', (group) =>
    group
      .get('/', async ({ db }) => {
        const todos = await db.select().from(todo);
        return todos;
      })
      .get(
        '/:id',
        async ({ params, db }) => {
          const result = await db
            .select()
            .from(todo)
            .where(eq(todo.id, params.id));

          if (result.length === 0) throw new NotFoundError('Todo not found');

          return result[0];
        },
        { params: todoIdParamSchema }
      )
      .post(
        '/',
        async ({ body, db }) => {
          const result = await db
            .insert(todo)
            .values({ title: body.title, description: body.description })
            .returning();

          return result[0];
        },
        {
          body: createTodoSchema,
        }
      )
      .put(
        '/:id',
        async ({ body, params, db }) => {
          const { id } = params;

          const result = await db
            .update(todo)
            .set({
              title: body.title,
              description: body.description,
              completed: body.completed,
            })
            .where(eq(todo.id, id))
            .returning();

          if (result.length === 0) throw new NotFoundError('Todo not found');

          return result[0];
        },
        { body: updateTodoSchema, params: todoIdParamSchema }
      )
      .delete(
        '/:id',
        async ({ params }) => {
          const { id } = params;
          const result = await db
            .delete(todo)
            .where(eq(todo.id, id))
            .returning();

          if (result.length === 0) throw new NotFoundError('Todo not found');

          return result[0];
        },
        { params: todoIdParamSchema }
      )
  );
