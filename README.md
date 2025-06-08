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

คู่มือนี้จะแนะนำวิธีติดตั้ง Node.js v22.x LTS บน Ubuntu โดยใช้ NodeSource ซึ่งเป็นวิธีที่ง่ายและรวดเร็วในการติดตั้ง Node เวอร์ชันล่าสุด

## ขั้นตอนการติดตั้ง

### 1. ลบ Node.js เวอร์ชันเก่า (ถ้ามี)

```bash
sudo apt remove nodejs -y
```

### 2. เพิ่ม NodeSource Repository สำหรับ Node.js v22.x

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
```

### 3. ติดตั้ง Node.js

```bash
sudo apt-get install -y nodejs
```

### 4. ตรวจสอบเวอร์ชันที่ติดตั้ง

```bash
node -v
npm -v
```

> คำสั่งด้านบนจะแสดงเวอร์ชันของ Node.js และ npm ที่ถูกติดตั้ง เช่น `v22.1.6` และ `10.x.x`

## หมายเหตุเพิ่มเติม

* หากต้องการจัดการ Node.js หลายเวอร์ชันบนเครื่องเดียว สามารถใช้ `nvm (Node Version Manager)` แทนการติดตั้งแบบนี้ได้
* Node.js v22 เป็นเวอร์ชัน LTS (Long Term Support) เหมาะสำหรับใช้งานใน production

## แหล่งอ้างอิง

* NodeSource: [https://github.com/nodesource/distributions](https://github.com/nodesource/distributions)
* Node.js LTS Schedule: [https://nodejs.org/en/about/releases/](https://nodejs.org/en/about/releases/)

---

**จัดทำโดย:** Yu
