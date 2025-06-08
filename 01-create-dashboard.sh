#!/bin/bash

# Dashboard Generator Script for React + Vite + Tailwind CSS
# วิธีใช้: chmod +x create-dashboard.sh && ./create-dashboard.sh

echo "🚀 Creating Dashboard Structure..."

# สร้างโฟลเดอร์หลัก
mkdir -p src/components/Dashboard
mkdir -p src/components/UI
mkdir -p src/pages/Dashboard
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/assets/icons

echo "📁 Created folder structure"

# สร้าง Main Dashboard Layout
cat > src/components/Dashboard/DashboardLayout.jsx << 'EOF'
import { useState } from 'react'
import Sidebar from './Sidebar'
import Header from './Header'
import MobileSidebar from './MobileSidebar'

export default function DashboardLayout({ children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false)

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar */}
      <MobileSidebar 
        sidebarOpen={sidebarOpen} 
        setSidebarOpen={setSidebarOpen} 
      />

      {/* Static sidebar for desktop */}
      <Sidebar />

      <div className="lg:pl-64 flex flex-col flex-1">
        <Header setSidebarOpen={setSidebarOpen} />
        
        <main className="flex-1">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}
EOF

# สร้าง Sidebar Component
cat > src/components/Dashboard/Sidebar.jsx << 'EOF'
import { NavLink } from 'react-router-dom'

const navigation = [
  { name: 'หน้าหลัก', href: '/dashboard', icon: '🏠' },
  { name: 'สถิติ', href: '/dashboard/analytics', icon: '📊' },
  { name: 'ผู้ใช้งาน', href: '/dashboard/users', icon: '👥' },
  { name: 'รายงาน', href: '/dashboard/reports', icon: '📋' },
  { name: 'การตั้งค่า', href: '/dashboard/settings', icon: '⚙️' },
]

export default function Sidebar() {
  return (
    <div className="hidden lg:fixed lg:inset-y-0 lg:z-40 lg:flex lg:w-64 lg:flex-col">
      <div className="flex min-h-0 flex-1 flex-col bg-white border-r border-gray-200">
        <div className="flex flex-1 flex-col overflow-y-auto pt-5 pb-4">
          <div className="flex flex-shrink-0 items-center px-4">
            <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>
          </div>
          <nav className="mt-8 flex-1 space-y-1 px-2">
            {navigation.map((item) => (
              <NavLink
                key={item.name}
                to={item.href}
                className={({ isActive }) =>
                  `group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors ${
                    isActive
                      ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-700'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`
                }
              >
                <span className="mr-3 text-lg">{item.icon}</span>
                {item.name}
              </NavLink>
            ))}
          </nav>
        </div>
      </div>
    </div>
  )
}
EOF

# สร้าง Header Component
cat > src/components/Dashboard/Header.jsx << 'EOF'
import { useState } from 'react'

export default function Header({ setSidebarOpen }) {
  const [userMenuOpen, setUserMenuOpen] = useState(false)

  return (
    <div className="sticky top-0 z-10 bg-white shadow-sm border-b border-gray-200">
      <div className="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        <div className="flex items-center">
          {/* Mobile menu button */}
          <button
            type="button"
            className="lg:hidden -ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500"
            onClick={() => setSidebarOpen(true)}
          >
            <span className="sr-only">Open sidebar</span>
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>

          <h2 className="ml-4 text-lg font-semibold text-gray-900 lg:ml-0">
            Dashboard Overview
          </h2>
        </div>

        <div className="flex items-center space-x-4">
          {/* Notification button */}
          <button className="bg-white p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            <span className="sr-only">View notifications</span>
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
          </button>

          {/* Profile dropdown */}
          <div className="relative">
            <button
              className="bg-white rounded-full flex text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              onClick={() => setUserMenuOpen(!userMenuOpen)}
            >
              <span className="sr-only">Open user menu</span>
              <div className="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center">
                <span className="text-white text-sm font-medium">U</span>
              </div>
            </button>

            {userMenuOpen && (
              <div className="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5">
                <div className="py-1">
                  <a href="#" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                    โปรไฟล์
                  </a>
                  <a href="#" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                    การตั้งค่า
                  </a>
                  <a href="#" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                    ออกจากระบบ
                  </a>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# สร้าง Mobile Sidebar
cat > src/components/Dashboard/MobileSidebar.jsx << 'EOF'
import { Fragment } from 'react'
import { NavLink } from 'react-router-dom'

const navigation = [
  { name: 'หน้าหลัก', href: '/dashboard', icon: '🏠' },
  { name: 'สถิติ', href: '/dashboard/analytics', icon: '📊' },
  { name: 'ผู้ใช้งาน', href: '/dashboard/users', icon: '👥' },
  { name: 'รายงาน', href: '/dashboard/reports', icon: '📋' },
  { name: 'การตั้งค่า', href: '/dashboard/settings', icon: '⚙️' },
]

export default function MobileSidebar({ sidebarOpen, setSidebarOpen }) {
  if (!sidebarOpen) return null

  return (
    <div className="lg:hidden">
      <div className="fixed inset-0 z-50 flex">
        {/* Overlay */}
        <div 
          className="fixed inset-0 bg-gray-600 bg-opacity-75"
          onClick={() => setSidebarOpen(false)}
        />

        {/* Sidebar */}
        <div className="relative flex w-full max-w-xs flex-1 flex-col bg-white">
          <div className="absolute top-0 right-0 -mr-12 pt-2">
            <button
              type="button"
              className="ml-1 flex h-10 w-10 items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
              onClick={() => setSidebarOpen(false)}
            >
              <span className="sr-only">Close sidebar</span>
              <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <div className="flex min-h-0 flex-1 flex-col pt-5 pb-4">
            <div className="flex flex-shrink-0 items-center px-4">
              <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>
            </div>
            <nav className="mt-8 flex-1 space-y-1 px-2">
              {navigation.map((item) => (
                <NavLink
                  key={item.name}
                  to={item.href}
                  onClick={() => setSidebarOpen(false)}
                  className={({ isActive }) =>
                    `group flex items-center px-2 py-2 text-base font-medium rounded-md transition-colors ${
                      isActive
                        ? 'bg-blue-50 text-blue-700'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    }`
                  }
                >
                  <span className="mr-4 text-lg">{item.icon}</span>
                  {item.name}
                </NavLink>
              ))}
            </nav>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# สร้าง Stats Cards Component
cat > src/components/UI/StatsCard.jsx << 'EOF'
export default function StatsCard({ title, value, change, changeType, icon }) {
  const changeColor = changeType === 'increase' ? 'text-green-600' : 'text-red-600'
  const changeBg = changeType === 'increase' ? 'bg-green-50' : 'bg-red-50'

  return (
    <div className="bg-white overflow-hidden shadow-sm rounded-lg border border-gray-200 hover:shadow-md transition-shadow">
      <div className="p-6">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <div className="text-2xl">{icon}</div>
          </div>
          <div className="ml-4 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-500 truncate">
                {title}
              </dt>
              <dd className="flex items-baseline">
                <div className="text-2xl font-semibold text-gray-900">
                  {value}
                </div>
                {change && (
                  <div className={`ml-2 flex items-baseline text-sm font-semibold ${changeColor}`}>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${changeBg} ${changeColor}`}>
                      {changeType === 'increase' ? '↗' : '↘'} {change}
                    </span>
                  </div>
                )}
              </dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# สร้าง Main Dashboard Page
cat > src/pages/Dashboard/DashboardHome.jsx << 'EOF'
import StatsCard from '../../components/UI/StatsCard'

const stats = [
  {
    title: 'ผู้ใช้งานทั้งหมด',
    value: '12,345',
    change: '+12%',
    changeType: 'increase',
    icon: '👥'
  },
  {
    title: 'ยอดขายวันนี้',
    value: '฿85,240',
    change: '+8.2%',
    changeType: 'increase',
    icon: '💰'
  },
  {
    title: 'คำสั่งซื้อ',
    value: '1,234',
    change: '-2.1%',
    changeType: 'decrease',
    icon: '📦'
  },
  {
    title: 'อัตราการแปลง',
    value: '3.24%',
    change: '+1.2%',
    changeType: 'increase',
    icon: '📈'
  }
]

export default function DashboardHome() {
  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg shadow-lg">
        <div className="px-6 py-8 text-white">
          <h1 className="text-3xl font-bold">ยินดีต้อนรับสู่ Dashboard</h1>
          <p className="mt-2 text-blue-100">
            ภาพรวมข้อมูลและสถิติการใช้งานของคุณ
          </p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat, index) => (
          <StatsCard
            key={index}
            title={stat.title}
            value={stat.value}
            change={stat.change}
            changeType={stat.changeType}
            icon={stat.icon}
          />
        ))}
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Chart 1 */}
        <div className="bg-white shadow-sm rounded-lg border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">ยอดขายรายสัปดาห์</h3>
          </div>
          <div className="p-6">
            <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
              <p className="text-gray-500">Chart Component จะอยู่ตรงนี้</p>
            </div>
          </div>
        </div>

        {/* Chart 2 */}
        <div className="bg-white shadow-sm rounded-lg border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">ผู้ใช้งานใหม่</h3>
          </div>
          <div className="p-6">
            <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
              <p className="text-gray-500">Chart Component จะอยู่ตรงนี้</p>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white shadow-sm rounded-lg border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">กิจกรรมล่าสุด</h3>
        </div>
        <div className="divide-y divide-gray-200">
          {[1, 2, 3, 4, 5].map((item) => (
            <div key={item} className="px-6 py-4 flex items-center space-x-4">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 bg-blue-500 rounded-full flex items-center justify-center">
                  <span className="text-white text-sm">👤</span>
                </div>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">
                  ผู้ใช้งานใหม่ลงทะเบียน
                </p>
                <p className="text-sm text-gray-500">
                  2 นาทีที่แล้ว
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
EOF

# สร้างหน้าอื่นๆ
cat > src/pages/Dashboard/Analytics.jsx << 'EOF'
export default function Analytics() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
      <div className="bg-white shadow-sm rounded-lg border border-gray-200 p-6">
        <p className="text-gray-600">หน้า Analytics - แสดงกราฟและสถิติต่างๆ</p>
      </div>
    </div>
  )
}
EOF

cat > src/pages/Dashboard/Users.jsx << 'EOF'
export default function Users() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">จัดการผู้ใช้งาน</h1>
      <div className="bg-white shadow-sm rounded-lg border border-gray-200 p-6">
        <p className="text-gray-600">หน้าจัดการผู้ใช้งาน - แสดงรายชื่อและข้อมูลผู้ใช้</p>
      </div>
    </div>
  )
}
EOF

cat > src/pages/Dashboard/Reports.jsx << 'EOF'
export default function Reports() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">รายงาน</h1>
      <div className="bg-white shadow-sm rounded-lg border border-gray-200 p-6">
        <p className="text-gray-600">หน้ารายงาน - แสดงรายงานต่างๆ</p>
      </div>
    </div>
  )
}
EOF

cat > src/pages/Dashboard/Settings.jsx << 'EOF'
export default function Settings() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">การตั้งค่า</h1>
      <div className="bg-white shadow-sm rounded-lg border border-gray-200 p-6">
        <p className="text-gray-600">หน้าการตั้งค่า - ตั้งค่าระบบต่างๆ</p>
      </div>
    </div>
  )
}
EOF

# สร้าง Custom Hook สำหรับ Dashboard
cat > src/hooks/useDashboard.js << 'EOF'
import { useState, useEffect } from 'react'

export function useDashboard() {
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({})
  const [error, setError] = useState(null)

  useEffect(() => {
    // Simulate API call
    const fetchDashboardData = async () => {
      try {
        setLoading(true)
        // Mock data - ในโปรเจคจริงจะเรียก API
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        setStats({
          totalUsers: 12345,
          totalSales: 85240,
          totalOrders: 1234,
          conversionRate: 3.24
        })
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    fetchDashboardData()
  }, [])

  return { loading, stats, error }
}
EOF

# สร้าง Utility functions
cat > src/utils/format.js << 'EOF'
export const formatCurrency = (amount) => {
  return new Intl.NumberFormat('th-TH', {
    style: 'currency',
    currency: 'THB'
  }).format(amount)
}

export const formatNumber = (number) => {
  return new Intl.NumberFormat('th-TH').format(number)
}

export const formatPercentage = (value) => {
  return `${value}%`
}

export const formatDate = (date) => {
  return new Intl.DateTimeFormat('th-TH', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }).format(new Date(date))
}
EOF

# สร้าง App.jsx ที่อัพเดท
cat > src/App.jsx << 'EOF'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import DashboardLayout from './components/Dashboard/DashboardLayout'
import DashboardHome from './pages/Dashboard/DashboardHome'
import Analytics from './pages/Dashboard/Analytics'
import Users from './pages/Dashboard/Users'
import Reports from './pages/Dashboard/Reports'
import Settings from './pages/Dashboard/Settings'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={
          <DashboardLayout>
            <DashboardHome />
          </DashboardLayout>
        } />
        <Route path="/dashboard/analytics" element={
          <DashboardLayout>
            <Analytics />
          </DashboardLayout>
        } />
        <Route path="/dashboard/users" element={
          <DashboardLayout>
            <Users />
          </DashboardLayout>
        } />
        <Route path="/dashboard/reports" element={
          <DashboardLayout>
            <Reports />
          </DashboardLayout>
        } />
        <Route path="/dashboard/settings" element={
          <DashboardLayout>
            <Settings />
          </DashboardLayout>
        } />
      </Routes>
    </Router>
  )
}

export default App
EOF

# สร้าง package.json dependencies ที่ต้องเพิ่ม
cat > dashboard-dependencies.txt << 'EOF'
Dependencies ที่ต้องติดตั้งเพิ่มเติม:

npm install react-router-dom
# สำหรับ routing ระหว่างหน้า

# Optional - สำหรับ Charts
npm install recharts
# หรือ
npm install chart.js react-chartjs-2

# Optional - สำหรับ Icons
npm install lucide-react
# หรือ
npm install @heroicons/react
EOF

echo "✅ Dashboard structure created successfully!"
echo ""
echo "📁 Files created:"
echo "   - Components: DashboardLayout, Sidebar, Header, MobileSidebar"
echo "   - UI Components: StatsCard"  
echo "   - Pages: DashboardHome, Analytics, Users, Reports, Settings"
echo "   - Hooks: useDashboard"
echo "   - Utils: format functions"
echo "   - Updated App.jsx with routing"
echo ""
echo "📋 Next steps:"
echo "   1. ติดตั้ง dependencies: npm install react-router-dom"
echo "   2. เริ่มต้น dev server: npm run dev"
echo "   3. เข้าไปที่ http://localhost:5173/dashboard"
echo ""
echo "🎨 Customization:"
echo "   - เปลี่ยนสี theme ใน Tailwind classes"
echo "   - เพิ่ม Charts libraries ตามต้องการ"
echo "   - เพิ่ม API calls ใน hooks"
echo "   - เปลี่ยน Navigation items ใน Sidebar"
echo ""
echo "🚀 Dashboard is ready to use!"
EOF

chmod +x create-dashboard.sh


echo "✅ Script created! Run with: chmod +x create-dashboard.sh && ./create-dashboard.sh"