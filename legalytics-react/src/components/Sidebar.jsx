import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    Home,
    LayoutDashboard,
    MessageSquare,
    Gamepad2,
    Newspaper,
    User,
    LogOut,
    BookOpen,
    Trophy,
    Scale
} from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { motion } from 'framer-motion';

const Sidebar = () => {
    const { logout } = useAuth();

    const navItems = [
        { to: '/', icon: Home, label: 'Home' },
        { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
        { to: '/chatbot', icon: MessageSquare, label: 'NEEDHi AI' },
        { to: '/learning', icon: BookOpen, label: 'Learning' },
        { to: '/news', icon: Newspaper, label: 'News' },
        { to: '/games', icon: Gamepad2, label: 'Games' },
        { to: '/leaderboard', icon: Trophy, label: 'Leaderboard' },
        { to: '/profile', icon: User, label: 'Profile' },
    ];

    return (
        <aside className="hidden md:flex flex-col w-72 bg-white/80 backdrop-blur-xl border-r border-gray-100 min-h-screen sticky top-0 h-screen overflow-y-auto z-20">
            <div className="p-8 flex items-center gap-4">
                <motion.div
                    whileHover={{ rotate: 360 }}
                    transition={{ duration: 0.8 }}
                    className="w-12 h-12 premium-gradient rounded-2xl flex items-center justify-center shadow-xl shadow-primary/40 text-white"
                >
                    <Scale size={24} />
                </motion.div>
                <div className="flex flex-col">
                    <span className="font-black text-2xl text-gray-900 tracking-tighter leading-none">Legalytics</span>
                    <span className="text-[10px] font-black text-primary uppercase tracking-[0.3em] mt-1">Platform</span>
                </div>
            </div>

            <nav className="flex-1 px-6 py-8 space-y-2">
                {navItems.map((item) => (
                    <NavLink
                        key={item.to}
                        to={item.to}
                        className={({ isActive }) => `
                            group flex items-center gap-4 px-5 py-4 rounded-[20px] font-black tracking-tight transition-all duration-300 relative
                            ${isActive
                                ? 'bg-primary text-white shadow-2xl shadow-primary/30'
                                : 'text-gray-400 hover:text-gray-900 hover:bg-gray-50'}
                        `}
                    >
                        <item.icon size={22} className="relative z-10" />
                        <span className="relative z-10">{item.label}</span>

                        {/* Subtle active indicator dot */}
                        {item.to === window.location.pathname && (
                            <div className="absolute right-4 w-1.5 h-1.5 rounded-full bg-white opacity-100 shadow-[0_0_10px_white]" />
                        )}
                    </NavLink>
                ))}
            </nav>

            <div className="p-8 space-y-4">
                <div className="bg-gray-50 rounded-3xl p-5 border border-gray-100 relative overflow-hidden group">
                    <div className="relative z-10">
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Session ID</p>
                        <p className="text-xs font-bold text-gray-600 truncate">#882-991-XLA</p>
                    </div>
                    <div className="absolute -right-4 -bottom-4 w-12 h-12 bg-primary/5 rounded-full group-hover:scale-150 transition-transform"></div>
                </div>

                <button
                    onClick={logout}
                    className="flex items-center gap-4 px-5 py-4 w-full rounded-[20px] font-black text-red-500 hover:bg-red-50 transition-all active:scale-95"
                >
                    <LogOut size={22} />
                    <span>Sign Out</span>
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
