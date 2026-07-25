import React from 'react';
import {
    Gamepad2,
    Target,
    BookOpen,
    Users,
    Car,
    Search,
    ChevronRight,
    Star,
    Trophy,
    Sparkles
} from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
    const navigate = useNavigate();
    const containerVariants = {
        hidden: { opacity: 0 },
        visible: {
            opacity: 1,
            transition: { staggerChildren: 0.1 }
        }
    };

    const cardVariants = {
        hidden: { y: 20, opacity: 0 },
        visible: { y: 0, opacity: 1 }
    };

    const cards = [
        {
            title: 'Legal Content',
            desc: 'Explore modules on Fundamental Rights, IPC, and more.',
            icon: BookOpen,
            color: 'bg-blue-600',
            badge: 'Lvl 12',
            xp: '200 XP',
            path: '/learning'
        },
        {
            title: 'Easy Quiz',
            desc: 'Basic questions to build your legal foundation.',
            icon: Target,
            color: 'bg-emerald-600',
            badge: 'Unlocked',
            xp: '100 XP',
            path: '/quiz'
        },
        {
            title: 'Hard Quiz',
            desc: 'Challenge yourself with complex legal scenarios.',
            icon: Trophy,
            color: 'bg-orange-600',
            badge: 'Master',
            xp: '500 XP',
            path: '/quiz'
        },
        {
            title: 'Match Game',
            desc: 'Match the specific law to its legal description.',
            icon: Search,
            color: 'bg-indigo-600',
            badge: 'Popular',
            xp: '150 XP',
            path: '/games/match'
        },
        {
            title: 'Mock Parliament',
            desc: 'Simulate a session and debate major Indian bills.',
            icon: Users,
            color: 'bg-purple-600',
            badge: 'New',
            xp: '300 XP',
            path: '/parliament'
        },
        {
            title: 'Traffic Runner',
            desc: 'Dodge obstacles and learn traffic laws in real-time.',
            icon: Car,
            color: 'bg-pink-600',
            badge: 'Game',
            xp: '250 XP',
            path: '/games/runner'
        }
    ];

    return (
        <motion.div
            initial="hidden"
            animate="visible"
            variants={containerVariants}
            className="max-w-6xl mx-auto space-y-12 pb-10"
        >
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
                <motion.div variants={cardVariants}>
                    <div className="flex items-center gap-2 text-primary font-black text-xs uppercase tracking-widest mb-3">
                        <Sparkles size={14} /> Knowledge Frontier
                    </div>
                    <h1 className="text-5xl font-black text-gray-900 tracking-tight mb-2">Learning Hub</h1>
                    <p className="text-gray-500 font-bold text-lg">Master the laws of India through immersive experiences.</p>
                </motion.div>

                <motion.div
                    variants={cardVariants}
                    whileHover={{ scale: 1.05 }}
                    className="flex items-center gap-4 bg-white/80 backdrop-blur-xl px-7 py-5 rounded-[32px] border border-gray-100 shadow-xl shadow-gray-200/40 relative overflow-hidden group cursor-pointer"
                >
                    <div className="w-12 h-12 bg-yellow-100 rounded-2xl flex items-center justify-center text-yellow-600 group-hover:rotate-12 transition-transform">
                        <Star size={24} fill="currentColor" />
                    </div>
                    <div>
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Current Standing</p>
                        <p className="text-xl font-black text-gray-900">Elite IV Ranking</p>
                    </div>
                    <div className="absolute -right-4 -bottom-4 w-20 h-20 bg-yellow-500/5 rounded-full blur-2xl group-hover:bg-yellow-500/10 transition-colors"></div>
                </motion.div>
            </div>

            <motion.div
                variants={containerVariants}
                className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
            >
                {cards.map((card, idx) => (
                    <motion.div
                        key={idx}
                        variants={cardVariants}
                        whileHover={{ y: -12, scale: 1.02 }}
                        className="group bg-white p-8 rounded-[48px] shadow-sm border border-gray-100 flex flex-col justify-between transition-all relative overflow-hidden h-[420px]"
                    >
                        {/* Decorative background shape */}
                        <div className={`absolute top-0 right-0 w-32 h-32 ${card.color.replace('bg-', 'bg-')}/5 rounded-bl-[100px] -z-0 transition-all group-hover:w-40 group-hover:h-40`} />

                        <div className="relative z-10">
                            <div className="flex items-center justify-between mb-8">
                                <div className={`w-16 h-16 ${card.color} rounded-2xl flex items-center justify-center text-white shadow-2xl shadow-${card.color.split('-')[1]}-500/30 group-hover:scale-110 transition-transform`}>
                                    <card.icon size={32} />
                                </div>
                                <div className="bg-gray-50/80 backdrop-blur-sm px-4 py-1.5 rounded-full border border-gray-100">
                                    <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">{card.badge}</span>
                                </div>
                            </div>
                            <h3 className="text-3xl font-black text-gray-900 mb-3 tracking-tight">{card.title}</h3>
                            <p className="text-gray-500 font-bold text-sm leading-relaxed mb-8 opacity-80 group-hover:opacity-100 transition-opacity">
                                {card.desc}
                            </p>
                        </div>

                        <div className="relative z-10 space-y-4">
                            <div className="flex items-center gap-2 mb-2">
                                <div className="h-1 flex-1 bg-gray-100 rounded-full overflow-hidden">
                                    <motion.div
                                        initial={{ width: 0 }}
                                        animate={{ width: '65%' }}
                                        className={`h-full ${card.color}`}
                                    />
                                </div>
                                <span className="text-[10px] font-black text-gray-400">{card.xp}</span>
                            </div>
                            <button
                                onClick={() => navigate(card.path)}
                                className={`${card.color} text-white w-full py-5 rounded-[24px] font-black flex items-center justify-center gap-3 shadow-xl shadow-${card.color.split('-')[1]}-500/20 hover:brightness-110 active:scale-95 transition-all text-sm uppercase tracking-widest`}
                            >
                                Launch Module <ChevronRight size={18} />
                            </button>
                        </div>
                    </motion.div>
                ))}
            </motion.div>
        </motion.div>
    );
};

export default Dashboard;
