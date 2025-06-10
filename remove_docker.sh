#!/bin/bash

# Script สำหรับลบ Docker ออกจาก Ubuntu อย่างสมบูรณ์
# ใช้งาน: chmod +x remove_docker.sh && sudo ./remove_docker.sh

set -e

echo "🔴 เริ่มต้นการลบ Docker จากระบบ..."
echo "⚠️  คำเตือน: การดำเนินการนี้จะลบ Docker และข้อมูลทั้งหมด (images, containers, volumes)"
read -p "คุณต้องการดำเนินการต่อหรือไม่? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "ยกเลิกการดำเนินการ"
    exit 1
fi

echo

# ฟังก์ชันสำหรับแสดงสถานะ
print_status() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1"
}

# 1. หยุดการทำงานของ Docker Services
echo "🛑 กำลังหยุด Docker services..."
systemctl stop docker 2>/dev/null || true
systemctl stop docker.socket 2>/dev/null || true
systemctl stop containerd 2>/dev/null || true
print_status "หยุด Docker services แล้ว"

# 2. ลบ Docker Packages
echo "📦 กำลังลบ Docker packages..."
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
apt-get purge -y docker docker-engine docker.io runc 2>/dev/null || true
snap remove docker 2>/dev/null || true
print_status "ลบ Docker packages แล้ว"

# 3. ลบ Docker network interface
echo "🌐 กำลังลบ Docker network interfaces..."
ip link delete docker0 2>/dev/null || true
ifconfig docker0 down 2>/dev/null || true
brctl delbr docker0 2>/dev/null || true

# ลบ Docker network interfaces อื่นๆ
for interface in $(ip link show | grep -E "br-|veth" | cut -d: -f2 | cut -d@ -f1 | tr -d ' '); do
    ip link delete "$interface" 2>/dev/null || true
done
print_status "ลบ Docker network interfaces แล้ว"

# 4. ลบ iptables rules
echo "🔥 กำลังลบ iptables rules..."
iptables -t nat -F DOCKER 2>/dev/null || true
iptables -t filter -F DOCKER 2>/dev/null || true
iptables -t filter -F DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
iptables -t filter -F DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
iptables -t filter -F DOCKER-USER 2>/dev/null || true

iptables -t nat -X DOCKER 2>/dev/null || true
iptables -t filter -X DOCKER 2>/dev/null || true
iptables -t filter -X DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
iptables -t filter -X DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
iptables -t filter -X DOCKER-USER 2>/dev/null || true
print_status "ลบ iptables rules แล้ว"

# 5. ลบไฟล์และโฟลเดอร์ที่เกี่ยวข้อง
echo "🗑️  กำลังลบไฟล์และโฟลเดอร์ Docker..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf ~/.docker
rm -rf /var/run/docker.sock
rm -rf /var/run/docker
rm -rf /etc/systemd/system/docker.service.d
rm -rf /lib/systemd/system/docker.service
rm -rf /lib/systemd/system/docker.socket
print_status "ลบไฟล์และโฟลเดอร์ Docker แล้ว"

# 6. ลบ Docker User Group
echo "👥 กำลังลบ Docker user group..."
groupdel docker 2>/dev/null || true
print_status "ลบ Docker user group แล้ว"

# 7. ทำความสะอาดระบบ
echo "🧹 กำลังทำความสะอาดระบบ..."
apt-get autoremove -y
apt-get autoclean
systemctl daemon-reload
print_status "ทำความสะอาดระบบแล้ว"

# 8. Restart network services
echo "🔄 กำลัง restart network services..."
systemctl restart networking 2>/dev/null || true
systemctl restart NetworkManager 2>/dev/null || true
print_status "Restart network services แล้ว"

echo
echo "🎉 ลบ Docker เสร็จสิ้น!"
echo

# 9. ตรวจสอบผลลัพธ์
echo "📋 ตรวจสอบผลลัพธ์:"
echo "----------------------------------------"

echo "🔍 Docker packages ที่เหลือ:"
if dpkg -l | grep docker | grep -v grep; then
    print_error "ยังมี Docker packages เหลืออยู่"
else
    print_status "ไม่มี Docker packages เหลือ"
fi

echo
echo "🔍 Docker processes ที่เหลือ:"
if ps aux | grep docker | grep -v grep; then
    print_error "ยังมี Docker processes เหลืออยู่"
else
    print_status "ไม่มี Docker processes เหลือ"
fi

echo
echo "🔍 Docker network interfaces ที่เหลือ:"
if ip link show | grep docker; then
    print_error "ยังมี Docker network interfaces เหลืออยู่"
else
    print_status "ไม่มี Docker network interfaces เหลือ"
fi

echo
echo "🔍 Docker systemd units ที่เหลือ:"
if systemctl list-units | grep docker | grep -v grep; then
    echo "⚠️  ยังมี Docker systemd units เหลืออยู่ (อาจจำเป็นต้อง reboot)"
    systemctl list-units | grep docker | grep -v grep
else
    print_status "ไม่มี Docker systemd units เหลือ"
fi

echo
echo "🔍 ตรวจสอบ Docker command:"
if command -v docker >/dev/null 2>&1; then
    print_error "ยังสามารถเรียกใช้คำสั่ง docker ได้"
else
    print_status "ไม่สามารถเรียกใช้คำสั่ง docker ได้แล้ว"
fi

echo
echo "----------------------------------------"
echo "✨ การลบ Docker เสร็จสิ้นแล้ว!"
echo "💡 หากยังพบ systemd device units เหลืออยู่ แนะนำให้ reboot เครื่อง:"
echo "   sudo reboot"
echo
