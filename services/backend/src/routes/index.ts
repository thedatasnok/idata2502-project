import Elysia from 'elysia';
import { todoRoutes } from './todo';

export const routes = new Elysia().use(todoRoutes);
