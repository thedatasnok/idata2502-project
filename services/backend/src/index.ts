import { Elysia } from 'elysia';
import { routes } from './routes';

const app = new Elysia().use(routes).listen(4000);

console.log(`Server listening on ${app.server?.hostname}:${app.server?.port}`);
