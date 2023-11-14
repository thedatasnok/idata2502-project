import { For, createResource, createSignal } from 'solid-js';

interface Todo {
  title: string;
  description: string;
  completed: boolean;
}

const listTodos = async () => {
  const response = await fetch('/api/v1/todos');
  const todos = await response.json();

  return todos as Todo[];
};

const createTodo = async (title: string) => {
  const response = await fetch('/api/v1/todos', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ title, description: null }),
  });
  const todo = await response.json();

  return todo as Todo;
};

const EmptyState = () => {
  return <li class='text-lg text-zinc-500 my-4'>No todos found</li>;
};

const App = () => {
  const [title, setTitle] = createSignal('');

  const [data, { refetch }] = createResource(listTodos);

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    createTodo(title()).then(() => refetch());
    setTitle('');
  };

  return (
    <main class='h-screen w-screen flex flex-col items-center justify-center'>
      <h1 class='font-semibold text-lg'>todo app</h1>

      <ul>
        <For each={data()} fallback={<EmptyState />}>
          {(todo) => <li>{todo.title}</li>}
        </For>
      </ul>

      <form onSubmit={handleSubmit}>
        <input
          type='text'
          value={title()}
          class='bg-transparent border-zinc-700 rounded-l-md border-l border-y focus:outline-none py-1 px-2 text-zinc-300 focus:border-indigo-600'
          onChange={(e) => setTitle(e.currentTarget.value)}
        />

        <button
          type='submit'
          class='rounded-r-md border border-indigo-700 bg-indigo-600 py-1 px-4 focus:outline-none focus:ring-2 ring-indigo-800'
        >
          Add
        </button>
      </form>
    </main>
  );
};

export default App;
