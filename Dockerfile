FROM node:22-alpine AS build
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
ARG VITE_APP_BASE_PATH
ARG VITE_PAYMENT_GATEWAY_API_BASE_URL
ARG VITE_USER_API_BASE_URL
ARG VITE_CONVERSA_APP_URL
ARG VITE_SSO_CLIENT_ID
ARG VITE_SSO_REDIRECT_URI
RUN pnpm build

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
RUN mkdir -p /var/cache/nginx/client_temp /var/run \
  && chown -R nginx:nginx /var/cache/nginx /var/run
EXPOSE 8081
USER nginx
