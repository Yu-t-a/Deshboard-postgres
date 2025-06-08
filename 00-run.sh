#!/bin/bash

echo "🚀 Creating Full Stack Project..."

# Create project structure
mkdir -p fullstack-docker-app
cd fullstack-docker-app

# Create docker-compose.yaml
cat > docker-compose.yaml << 'EOF'
version: '3.8'

services:
  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile
    container_name: frontend_app
    ports:
      - "80:80"
      - "443:443"
    networks:
      - app-network
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: backend_api
    environment:
      - NODE_ENV=production
      - PORT=3050
      - DATABASE_URL=postgresql://admin:password123@postgres:5432/myapp
    ports:
      - "3050:3050"
    networks:
      - app-network
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    container_name: postgres_db
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin_web
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    networks:
      - app-network
    depends_on:
      - postgres

volumes:
  postgres_data:
  pgadmin_data:

networks:
  app-network:
    driver: bridge
EOF

# Initialize Frontend with Vite
npm create vite@latest frontend -- --template react
cd frontend
npm install
cd ..

# Create Frontend Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create Frontend nginx.conf
cat > frontend/nginx.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:3050;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

cd fullstack-docker-app
# Initialize Backend
mkdir -p backend
cd backend
npm init -y
npm install express cors pg dotenv
cd ..

# Create Backend Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3050
CMD ["node", "server.js"]
EOF

# Create Backend server.js
cat > backend/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3050;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend is running!' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
EOF


# Create startup script
cat > start.sh << 'EOF'
#!/bin/bash
docker compose down 
docker compose up --build -d
EOF

chmod +x start.sh

echo "✅ Project created successfully!"
echo "📁 Directory: fullstack-docker-app"
echo "🚀 To start: ./start.sh"
echo "🌐 Access points:"
echo "   Frontend: http://localhost"
echo "   Backend API: http://localhost:3050"
echo "   pgAdmin: http://localhost:5050"