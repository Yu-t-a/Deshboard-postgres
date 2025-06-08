# Docker Reinstallation on Ubuntu

This guide provides step-by-step instructions for **removing** any existing Docker installation and **reinstalling** Docker on a Ubuntu system.

---

## 1. Uninstall Existing Docker

Stop Docker service if it's running:

```bash
sudo systemctl stop docker
```

Remove Docker packages and related files:

```bash
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli containerd runc
sudo rm -rf /var/lib/docker /etc/docker /var/run/docker.sock
sudo groupdel docker
sudo apt-get autoremove -y
sudo apt-get autoclean
```

Check system status:

```bash
lsb_release -a
 top
 df -h
```

---

## 2. Install Docker (Official Docker Engine)

### Step 1: Update package index and install dependencies

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
```

### Step 2: Add Docker's GPG key and set up repository

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 3: Install Docker Engine and plugins

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 4: (Optional) Add current user to the `docker` group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 3. Verify Docker Installation

Run the hello-world image to verify Docker is working:

```bash
docker run hello-world
```

Expected output should confirm that:

* Docker client contacted the Docker daemon
* Docker pulled the image from Docker Hub
* A container ran successfully and returned output

---

## Resources

* [Docker Official Installation Docs](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Hub](https://hub.docker.com/)

---

**Status: Docker installed and verified successfully.**

# ติดตั้ง Node.js v22.x LTS บน Ubuntu
ติดตั้ง nvm
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
source ~/.bashrc   # หรือ source ~/.zshrc ขึ้นกับ shell ที่ใช้

```

เช็คเวอร์ชัน Node ที่ติดตั้งอยู่ ด้วยคำสั่ง
```
nvm ls
```
ลบเวอร์ชัน Node ที่ต้องการ (เช่น v21.0.0) ด้วยคำสั่ง
```
nvm uninstall 21.0.0
```
ถ้าอยากลบ NVM ทั้งหมด (รวม Node ทุกเวอร์ชันและตัว NVM เอง) ให้ลบโฟลเดอร์ NVM และลบคำสั่งโหลด NVM จากไฟล์ config shell เช่น .bashrc, .zshrc
```
rm -rf ~/.nvm
```
ตัวอย่าง
```
nvm ls
->      v21.0.0
       v22.14.0
default -> lts/* (-> N/A)
iojs -> N/A (default)
```

1. ลบ Node.js เวอร์ชันที่ติดตั้งทั้งหมดผ่าน nvm
```
nvm uninstall 21.0.0
nvm uninstall 22.14.0
```
2. ติดตั้ง Node.js v22.14.0 ใหม่
```
nvm install 22.14.0
```
3. ตั้งให้ v22.14.0 เป็น default version
```
nvm alias default 22.14.0
```
Update npm
```
npm install -g npm@11.3.0
```

การแปลงรูปแบบ line ending ระหว่างระบบ Unix (Linux/macOS ใช้ LF) และ Windows (ใช้ CRLF) เมื่อใช้ Git บน Windows
```
git config --global core.autocrlf input

git add .
```

# Step 01
Run file .sh
```
./00-run.sh
```
cp fullstack-docker-app
```
./dev.sh
```
# Step end
Frontend: http://localhost

Backend API: http://localhost:3050

pgAdmin: http://localhost:5050

Edit file on vscode Ubuntu
```
sudo chown -R $USER:$USER .
```
