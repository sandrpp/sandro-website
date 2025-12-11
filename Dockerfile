FROM node:22-alpine AS build
WORKDIR /app

# WICHTIG: package-lock.json statt yarn.lock kopieren
COPY package.json package-lock.json ./

# npm ci ist das npm-Äquivalent zu "frozen-lockfile" (sicherer & schneller)
RUN npm ci

COPY . .

# Build starten
RUN npm run build

# --- Ab hier bleibt alles exakt gleich wie vorher ---
FROM nginx:1.27-alpine AS runtime
RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/dist /usr/share/nginx/html
COPY config/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]