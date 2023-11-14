FROM oven/bun:alpine AS builder

WORKDIR /app

COPY package.json ./
COPY bun.lockb ./

COPY services/backend/package.json ./services/backend/package.json
COPY services/frontend/package.json ./services/frontend/package.json

RUN bun install --frozen-lockfile

COPY services/backend/ ./services/backend/

WORKDIR /app/services/backend

LABEL org.opencontainers.image.source="https://github.com/thedatasnok/idata2502-project"
LABEL org.opencontainers.image.description="idata2502-project backend service"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["bun", "db:migrate", "&&", "bun", "start"]
