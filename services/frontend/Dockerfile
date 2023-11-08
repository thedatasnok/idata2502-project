FROM oven/bun:alpine

COPY package.json ./
COPY bun.lockb ./

COPY services/backend/package.json ./services/backend/package.json
COPY services/frontend/package.json ./services/frontend/package.json

RUN bun install --frozen-lockfile

# TODO

LABEL org.opencontainers.image.source="https://github.com/thedatasnok/idata2502-project"
LABEL org.opencontainers.image.description="idata2502-project backend service"
LABEL org.opencontainers.image.licenses="MIT"
