# Optional standalone frontend image. For the full stack (API + Postgres + /api proxy), use
# docker/Dockerfile.frontend and docker/docker-compose.yml from the repo root.
#
# Build from repo root:
#   docker build -f frontend/Dockerfile -t to5-frontend-standalone .

FROM node:20-alpine AS builder
WORKDIR /app

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

COPY frontend/ ./

ARG VITE_MAPBOX_ACCESS_TOKEN
ARG VITE_MAPBOX_STYLE_URL
ARG VITE_GOOGLE_PLACES_API_KEY
ARG VITE_API_URL

ENV VITE_MAPBOX_ACCESS_TOKEN=$VITE_MAPBOX_ACCESS_TOKEN \
    VITE_MAPBOX_STYLE_URL=$VITE_MAPBOX_STYLE_URL \
    VITE_GOOGLE_PLACES_API_KEY=$VITE_GOOGLE_PLACES_API_KEY \
    VITE_API_URL=$VITE_API_URL

RUN npm run build

FROM nginxinc/nginx-unprivileged:stable-alpine

COPY --chown=nginx:nginx --from=builder /app/dist /usr/share/nginx/html
COPY --chown=nginx:nginx frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
