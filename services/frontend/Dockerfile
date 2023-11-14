FROM oven/bun:alpine AS builder

WORKDIR /app

COPY package.json ./
COPY bun.lockb ./

COPY services/backend/package.json ./services/backend/package.json
COPY services/frontend/package.json ./services/frontend/package.json

RUN bun install --frozen-lockfile

COPY services/frontend/ ./services/frontend/

WORKDIR /app/services/frontend

RUN bun run build

FROM nginx:alpine AS runner

COPY --from=builder /app/services/frontend/dist /usr/share/nginx/html
COPY --from=builder /app/services/frontend/config/nginx.conf /etc/nginx/conf.d/default.conf

LABEL org.opencontainers.image.source="https://github.com/thedatasnok/idata2502-project"
LABEL org.opencontainers.image.description="idata2502-project frontend service"
LABEL org.opencontainers.image.licenses="MIT"
