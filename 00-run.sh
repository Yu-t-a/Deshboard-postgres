#!/bin/bash

echo "🚀 Creating Full Stack Project..."

# Create project structure
mkdir -p fullstack-docker-app
cd fullstack-docker-app

# Create docker-compose.yaml with volume mounts
cat > docker-compose.yaml << 'EOF'
version: '3.8'

services:
  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile.dev  # Changed to development Dockerfile
    container_name: frontend_app
    ports:
      - "80:5173"     # Map external port 80 -> internal port 5173
      - "443:5173"    # Map external port 443 -> internal port 5173
    networks:
      - app-network
    volumes:
      - ./frontend:/app  # Mount frontend source code
      - /app/node_modules  # Volume for node_modules
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev  # Changed to development Dockerfile
    container_name: backend_api
    environment:
      - NODE_ENV=development
      - PORT=3050
    #   - DATABASE_URL=postgresql://deshadmin:dEsh@dm1n@postgres_db:5432/workdb
      - DATABASE_URL=postgresql://deshadmin:dEsh%40dm1n@postgres_db:5432/workdb

    ports:
      - "3050:3050"
    networks:
      - app-network
    volumes:
      - ./backend:/app  # Mount backend source code
      - /app/node_modules  # Volume for node_modules
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    container_name: postgres_db
    environment:
      POSTGRES_DB: workdb
      POSTGRES_USER: deshadmin
      POSTGRES_PASSWORD: dEsh@dm1n
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
      PGADMIN_DEFAULT_PASSWORD: dEsh@p@ss
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
npm install react-router-dom

npm install -D tailwindcss@3.4.1 postcss autoprefixer
npx tailwindcss init -p
# ตรวจสอบ OS เพื่อเลือกตัวเลือก sed ที่ถูกต้อง
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  SED_OPT="-i ''"
else
  # Linux / WSL / Docker
  SED_OPT="-i"
fi
# แก้ไข tailwind.config.js ให้รองรับไฟล์ React
if [[ -f tailwind.config.js ]]; then
  sed $SED_OPT 's|content: \[\],|content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],|' tailwind.config.js
else
  echo "❌ tailwind.config.js not found"
  exit 1
fi

# สร้างไฟล์ CSS หลัก src/index.css และใส่ directive ของ tailwind
mkdir -p src
cat > src/index.css <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# แก้ไข src/main.jsx ให้ import ไฟล์ CSS
if [[ -f src/main.jsx ]]; then
  sed $SED_OPT '/import App from .\/App/ a\
import "./index.css";
' src/main.jsx
else
  echo "❌ src/main.jsx not found"
  exit 1
fi
echo "✅ Setup complete. You can now run 'npm run dev' inside $PROJECT_NAME"

cd ..

# Create Frontend Development Dockerfile
cat > frontend/Dockerfile.dev << 'EOF'
FROM node:22-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
EOF

# Create Frontend Production Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:22-alpine as build

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

# Initialize Backend
mkdir -p backend
cd backend
npm init -y
npm install express cors pg dotenv nodemon
cd ..

# Create Backend Development Dockerfile
cat > backend/Dockerfile.dev << 'EOF'
FROM node:22-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 3050
CMD ["npm", "run", "dev"]
EOF

# Create Backend Production Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:22-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3050
CMD ["node", "server.js"]
EOF

# Update Backend package.json with dev script
cat > backend/package.json << 'EOF'
{
  "name": "backend",
  "version": "1.0.0",
  "description": "",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "pg": "^8.10.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
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

// const pool = new Pool({
//   connectionString: process.env.DATABASE_URL
// });

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://deshadmin:dEsh@dm1n@postgres_db:5432/workdb',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to PostgreSQL:', err.stack);
  } else {
    console.log('Connected to PostgreSQL successfully');
    release();
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend is running!' });
});

// Database health check
app.get('/health/db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ 
      status: 'ok', 
      message: 'Database connection is healthy',
      timestamp: result.rows[0].now 
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      message: 'Database connection failed',
      error: error.message 
    });
  }
});

// GET: Read all materials
app.get('/api/mm_materials', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM mm_materials ORDER BY material_id');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching materials:', error);
    res.status(500).json({ message: 'Failed to fetch materials', error: error.message });
  }
});

// POST: Create new material
app.post('/api/mm_materials', async (req, res) => {
  const {
    material_id,
    material_desc,
    material_type,
    industry_sector,
    base_unit,
    material_group,
    gross_weight,
    net_weight,
    weight_unit,
    created_by,
    plant
  } = req.body;

  try {
    const query = `
      INSERT INTO mm_materials (
        material_id, material_desc, material_type, industry_sector,
        base_unit, material_group, gross_weight, net_weight, weight_unit,
        created_by, plant
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING *
    `;
    const values = [
      material_id, material_desc, material_type, industry_sector,
      base_unit, material_group, gross_weight, net_weight, weight_unit,
      created_by, plant
    ];

    const result = await pool.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error inserting material:', error);
    res.status(500).json({ message: 'Failed to insert material', error: error.message });
  }
});

// List of all table names
const tableList = [
  'mm_materials', 'mm_vendors', 'mm_purchase_orders', 'mm_po_items',
  'sd_customers', 'sd_sales_orders', 'sd_so_items', 'sd_billing',
  'pp_production_orders', 'pp_work_centers', 'pp_bom_header', 'pp_bom_items',
  'fi_chart_accounts', 'co_cost_centers', 'fi_general_ledger', 'fi_accounts_payable', 'fi_accounts_receivable'
];

// Dynamic route creation for each table
for (const table of tableList) {
  app.get(`/api/${table}`, async (req, res) => {
    try {
      const result = await pool.query(`SELECT * FROM ${table}`);
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: `Failed to fetch data from ${table}`, error: error.message });
    }
  });
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Create development startup script
cat > dev.sh << 'EOF'
#!/bin/bash
docker compose -f docker-compose.yaml down
docker compose -f docker-compose.yaml up --build -d
docker ps
sleep 5
docker cp init_tables.sql postgres_db:/init_tables.sql
sleep 5
docker exec -i postgres_db psql -U deshadmin -d workdb < init_tables.sql
# sleep 5
# docker exec -it postgres_db psql -U deshadmin -d workdb
# \dt
# \d mm_materials
# exit
EOF
chmod +x dev.sh

cd ..

cp init_tables.sql fullstack-docker-app/init_tables.sql

cp 01-create-dashboard.sh fullstack-docker-app/frontend/create-dashboard.sh

cd fullstack-docker-app/frontend
chmod +x create-dashboard.sh
./create-dashboard.sh
cd ..

./dev.sh
 
echo "✅ Project created successfully!"
echo "📁 Directory: fullstack-docker-app"
echo "🚀 To start development environment: ./dev.sh"
echo "🌐 Access points:"
echo "   Frontend: http://localhost"
echo "   Backend API: http://localhost:3050"
echo "   pgAdmin: http://localhost:5050"