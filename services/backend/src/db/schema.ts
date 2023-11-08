import { boolean, pgTable, text, uuid } from 'drizzle-orm/pg-core';

export const todo = pgTable('todo', {
  id: uuid('todo_id').primaryKey().defaultRandom(),
  title: text('title').notNull(),
  description: text('description'),
  completed: boolean('completed').notNull().default(false),
});
