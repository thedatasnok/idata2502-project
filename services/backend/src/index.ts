import { Elysia } from 'elysia';

const app = new Elysia().get('/', () => 'Hello, World').listen(3000);

console.log(`Server listening on ${app.server?.hostname}:${app.server?.port}`);
