# Dockerfile
FROM node:18-bullseye AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# production stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
# optional: limit memory via docker-compose
CMD ["nginx", "-g", "daemon off;"]