import { db } from '@/db/client';
import Elysia from 'elysia';

export const persistence = new Elysia().decorate('db', db);
