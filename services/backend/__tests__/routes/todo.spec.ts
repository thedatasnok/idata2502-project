import { todoRoutes } from '@/routes/todo';
import { afterAll, beforeAll, describe, expect, it } from 'bun:test';
import Elysia from 'elysia';

type RequestMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

const createApiRequest = <T extends object>(
  relativeUrl: string,
  method: RequestMethod,
  body?: T
) => {
  return new Request(`http://localhost${relativeUrl}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
};

describe('Todo routes', () => {
  let elysia: Elysia;
  let createdTodoId: string;

  beforeAll(async () => {
    elysia = todoRoutes;
  });

  afterAll(() => {
    process.exit(0);
  });

  it('returns an empty list before insertion', async () => {
    const request = createApiRequest('/api/v1/todos', 'GET');

    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body).toBeArray();
    expect(body).toHaveLength(0);
  });

  it('creates a todo', async () => {
    const request = createApiRequest('/api/v1/todos', 'POST', {
      title: 'test',
      description: null,
    });

    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body.id).not.toBeNull();
    expect(body.title).toBe('test');
    expect(body.description).toBeNull();
    expect(body.completed).toBe(false);

    createdTodoId = body.id;
  });

  it('can find the created todo by id', async () => {
    const request = createApiRequest(`/api/v1/todos/${createdTodoId}`, 'GET');
    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body.id).not.toBeNull();
    expect(body.title).toBe('test');
    expect(body.description).toBeNull();
    expect(body.completed).toBe(false);
  });

  it('returns a list with one todo after insertion', async () => {
    const request = createApiRequest('/api/v1/todos', 'GET');
    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body).toBeArray();
    expect(body).toHaveLength(1);
  });

  it('updates a todo', async () => {
    const request = createApiRequest(`/api/v1/todos/${createdTodoId}`, 'PUT', {
      title: 'updated',
      description: null,
      completed: true,
    });

    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body.id).not.toBeNull();
    expect(body.id).toBe(createdTodoId);
    expect(body.title).toBe('updated');
    expect(body.description).toBeNull();
    expect(body.completed).toBe(true);
  });

  it('can delete a todo by id', async () => {
    const request = createApiRequest(
      `/api/v1/todos/${createdTodoId}`,
      'DELETE'
    );
    const response = await elysia.handle(request);
    const body = await response.json();

    expect(body).not.toBeNull();
    expect(body.id).toBe(createdTodoId);
  });
});
