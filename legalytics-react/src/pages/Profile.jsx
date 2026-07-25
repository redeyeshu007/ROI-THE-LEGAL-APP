import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
    User,
    Mail,
    Calendar,
    Trophy,
    Target,
    Flame,
    ShieldCheck,
    Award,
    Settings,
    LogOut,
    ChevronRight
} from 'lucide-react';
import { motion } from 'framer-motion';

const Profile = () => {
    const { user, logout } = useAuth();

    const stats = [
        { label: 'Total XP', value: '2,450', icon: Target, color: 'text-blue-500', bg: 'bg-blue-50' },
        { label: 'Quizzes', value: '18', icon: Trophy, color: 'text-orange-500', bg: 'bg-orange-50' },
        { label: 'Streak', value: '12 Days', icon: Flame, color: 'text-red-500', bg: 'bg-red-50' },
    ];

    const badges = [
        { name: 'Constitutionist', icon: ShieldCheck, color: 'text-emerald-500' },
        { name: 'Road Scholar', icon: Award, color: 'text-purple-500' },
        { name: 'Fast Learner', icon: Award, color: 'text-blue-500' },
    ];

    return (
        <div className="max-w-4xl mx-auto space-y-8">
            {/* Header Profile Card */}
            <div className="bg-white rounded-[40px] p-10 border border-gray-100 shadow-sm relative overflow-hidden">
                <div className="absolute top-0 right-0 p-8">
                    <button className="p-3 bg-gray-50 rounded-2xl border border-gray-100 text-gray-400 hover:text-primary transition-colors">
                        <Settings size={20} />
                    </button>
                </div>

                <div className="flex flex-col md:flex-row items-center gap-10">
                    <div className="relative">
                        <div className="w-32 h-32 rounded-[36px] overflow-hidden border-4 border-primary/20 p-1 bg-white">
                            {user?.photoURL ? (
                                <img src={user.photoURL} alt="Profile" className="w-full h-full object-cover rounded-[28px]" />
                            ) : (
                                <div className="w-full h-full bg-gray-50 flex items-center justify-center rounded-[28px]">
                                    <User size={48} className="text-gray-300" />
                                </div>
                            )}
                        </div>
                        <div className="absolute -bottom-2 -right-2 w-10 h-10 premium-gradient rounded-2xl flex items-center justify-center text-white border-4 border-white shadow-lg shadow-primary/30">
                            <span className="text-xs font-black">Lvl 12</span>
                        </div>
                    </div>

                    <div className="text-center md:text-left space-y-2">
                        <h1 className="text-3xl font-black text-gray-900">{user?.displayName || 'Citizen Scholar'}</h1>
                        <div className="flex flex-col gap-2">
                            <div className="flex items-center gap-2 text-gray-500 font-bold text-sm">
                                <Mail size={16} />
                                <span>{user?.email || 'citizen@email.com'}</span>
                            </div>
                            <div className="flex items-center gap-2 text-gray-500 font-bold text-sm">
                                <Calendar size={16} />
                                <span>Joined March 2024</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="mt-12 space-y-4">
                    <div className="flex items-center justify-between text-xs font-black uppercase tracking-widest">
                        <span className="text-gray-400">Level 12 Progress</span>
                        <span className="text-primary">2,450 / 3,000 XP</span>
                    </div>
                    <div className="h-4 bg-gray-100 rounded-full overflow-hidden">
                        <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: '82%' }}
                            className="h-full premium-gradient"
                        />
                    </div>
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {stats.map((stat, i) => (
                    <div key={i} className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm flex items-center gap-5">
                        <div className={`w-14 h-14 ${stat.bg} rounded-2xl flex items-center justify-center ${stat.color}`}>
                            <stat.icon size={28} />
                        </div>
                        <div>
                            <p className="text-gray-400 text-[10px] font-black uppercase tracking-widest">{stat.label}</p>
                            <p className="text-xl font-black text-gray-900">{stat.value}</p>
                        </div>
                    </div>
                ))}
            </div>

            {/* Badges & Achievements */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="bg-white p-8 rounded-[40px] border border-gray-100 shadow-sm">
                    <h3 className="text-xl font-black text-gray-900 mb-8 flex items-center gap-3">
                        <Award className="text-primary" /> Top Badges
                    </h3>
                    <div className="grid grid-cols-3 gap-4 text-center">
                        {badges.map((badge, i) => (
                            <div key={i} className="space-y-3 p-4 rounded-3xl bg-gray-50/50 border border-transparent hover:border-gray-100 transition-all">
                                <div className={`w-16 h-16 mx-auto rounded-2xl bg-white flex items-center justify-center shadow-sm ${badge.color}`}>
                                    <badge.icon size={32} />
                                </div>
                                <p className="text-[10px] font-black uppercase tracking-widest text-gray-500 leading-tight">{badge.name}</p>
                            </div>
                        ))}
                    </div>
                </div>

                <div className="bg-white p-8 rounded-[40px] border border-gray-100 shadow-sm flex flex-col justify-between">
                    <div className="space-y-6">
                        <h3 className="text-xl font-black text-gray-900 flex items-center gap-3">
                            <LogOut className="text-red-500" /> Account Settings
                        </h3>
                        <button className="w-full p-4 rounded-2xl border border-gray-100 flex items-center justify-between hover:bg-gray-50 transition-all group">
                            <span className="font-bold text-gray-600">Download Learning History</span>
                            <ChevronRight size={20} className="text-gray-300 group-hover:text-primary transition-colors" />
                        </button>
                        <button className="w-full p-4 rounded-2xl border border-gray-100 flex items-center justify-between hover:bg-gray-50 transition-all group text-red-500">
                            <span className="font-bold">Delete Account Data</span>
                            <ChevronRight size={20} className="text-gray-300 group-hover:text-red-500 transition-colors" />
                        </button>
                    </div>

                    <button
                        onClick={logout}
                        className="w-full mt-10 bg-red-50 text-red-500 py-4 rounded-2xl font-black flex items-center justify-center gap-3 hover:bg-red-100 transition-all border border-red-100"
                    >
                        Sign Out
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Profile;
