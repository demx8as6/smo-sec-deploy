# docker/nginx/Dockerfile

### Stage 1: Build the frontend ###
FROM node:20-alpine AS builder
WORKDIR /app
COPY src/service-deck/package*.json ./
RUN npm install
COPY src/service-deck .
RUN npm run build

### Stage 2: Serve with NGINX ###
FROM nginx:alpine
COPY docker/service-deck/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
