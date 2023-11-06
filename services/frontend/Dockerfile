FROM oven/bun:alpine

COPY package.json ./
COPY bun.lockb

COPY services/*/package.json .

RUN bun install --frozen-lockfile

# TODO