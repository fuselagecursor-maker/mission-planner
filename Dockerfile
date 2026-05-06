# API only — use when Railway builds from repo root (Flutter app is not in this image).
FROM node:20-alpine

WORKDIR /app

COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev || npm install --omit=dev

COPY backend/src ./src
COPY backend/sql ./sql

ENV NODE_ENV=production
ENV PORT=4000

EXPOSE 4000

CMD ["node", "src/server.js"]
