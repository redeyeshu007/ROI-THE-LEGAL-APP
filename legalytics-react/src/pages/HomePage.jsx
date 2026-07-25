import React from 'react';
import {
    Trophy,
    Flame,
    BookOpen,
    Shield,
    Gavel,
    Users,
    ChevronRight,
    TrendingUp,
    Clock,
    Sparkles,
    Star,
    Zap
} from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const HomePage = () => {
    const navigate = useNavigate();

    const containerVariants = {
        hidden: { opacity: 0 },
        visible: {
            opacity: 1,
            transition: { staggerChildren: 0.1, delayChildren: 0.2 }
        }
    };

    const itemVariants = {
        hidden: { y: 20, opacity: 0 },
        visible: { y: 0, opacity: 1 }
    };

    const modules = [
        { id: 1, title: 'Fundamental Rights', icon: Shield, color: 'bg-blue-600', lessons: 12, progress: 45, path: '/learning' },
        { id: 2, title: 'Indian Penal Code', icon: Gavel, color: 'bg-purple-600', lessons: 24, progress: 10, path: '/learning' },
        { id: 3, title: 'Cyber Laws', icon: BookOpen, color: 'bg-emerald-600', lessons: 8, progress: 80, path: '/learning' },
        { id: 4, title: 'Family Law', icon: Users, color: 'bg-amber-600', lessons: 15, progress: 0, path: '/learning' },
    ];

    return (
        <motion.div
            initial="hidden"
            animate="visible"
            variants={containerVariants}
            className="max-w-7xl mx-auto space-y-12 pb-16"
        >
            {/* Hero Section */}
            <motion.div
                variants={itemVariants}
                className="relative min-h-[450px] premium-gradient rounded-[48px] p-12 text-white overflow-hidden shadow-[0_30px_60px_-15px_rgba(108,58,237,0.3)]"
            >
                {/* Background Visuals */}
                <div className="absolute top-0 right-0 w-full h-full">
                    <motion.div
                        animate={{
                            scale: [1, 1.1, 1],
                            rotate: [0, 5, 0],
                            opacity: [0.1, 0.2, 0.1]
                        }}
                        transition={{ duration: 10, repeat: Infinity }}
                        className="absolute -top-20 -right-20 w-[600px] h-[600px] bg-white rounded-full blur-[120px]"
                    />
                    <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 mix-blend-overlay"></div>
                </div>

                <div className="relative z-10 max-w-2xl h-full flex flex-col justify-center">
                    <motion.div
                        initial={{ scale: 0.8, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="bg-white/20 backdrop-blur-xl px-5 py-2 rounded-full w-fit mb-8 border border-white/20 flex items-center gap-3"
                    >
                        <Sparkles size={16} className="text-yellow-300" />
                        <span className="text-xs font-black tracking-[0.2em] uppercase">Special Update: Vercel Alpha Hub</span>
                    </motion.div>

                    <h1 className="text-6xl lg:text-7xl font-black mb-8 leading-[0.95] tracking-tighter">
                        Empowering <br />
                        <span className="text-white/60 italic">Justice</span> Seekers.
                    </h1>

                    <p className="text-xl font-bold text-white/80 mb-10 leading-relaxed max-w-lg">
                        The definitive gamified platform for legal mastery. Learn, compete, and evolve your understanding of Indian Law.
                    </p>

                    <div className="flex flex-wrap gap-4">
                        <motion.button
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                            onClick={() => navigate('/dashboard')}
                            className="bg-white text-primary px-10 py-5 rounded-[24px] font-black flex items-center gap-3 shadow-2xl shadow-primary/40 text-lg transition-all"
                        >
                            Get Started <Zap size={20} />
                        </motion.button>
                        <motion.button
                            whileHover={{ bg: 'rgba(255,255,255,0.1)' }}
                            onClick={() => navigate('/parliament')}
                            className="bg-transparent border-2 border-white/30 px-10 py-5 rounded-[24px] font-black flex items-center gap-3 backdrop-blur-md text-lg transition-all"
                        >
                            Mock Courts
                        </motion.button>
                    </div>
                </div>

                {/* Floating Elements */}
                <div className="hidden lg:block absolute right-24 top-1/2 -translate-y-1/2">
                    <motion.div
                        animate={{ y: [0, -20, 0] }}
                        transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                        className="w-64 h-80 bg-white/10 backdrop-blur-2xl rounded-[40px] border border-white/20 p-8 shadow-2xl relative"
                    >
                        <div className="w-12 h-12 bg-white/20 rounded-2xl mb-6 flex items-center justify-center">
                            <Scale size={24} />
                        </div>
                        <div className="w-full h-2 bg-white/20 rounded-full mb-4"></div>
                        <div className="w-[80%] h-2 bg-white/20 rounded-full mb-4"></div>
                        <div className="w-[60%] h-2 bg-white/20 rounded-full mb-12"></div>
                        <div className="absolute bottom-8 left-8 right-8">
                            <div className="h-12 bg-white rounded-2xl flex items-center justify-center text-primary font-black">Verify Case</div>
                        </div>
                    </motion.div>
                </div>
            </motion.div>

            {/* Metrics Section */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {[
                    { label: 'Daily Streak', value: '12 Days', icon: Flame, color: 'text-orange-500', bg: 'bg-orange-50' },
                    { label: 'Platform XP', value: '2,450', icon: TrendingUp, color: 'text-blue-500', bg: 'bg-blue-50', sub: '+150 today' },
                    { label: 'Global Rank', value: '#452', icon: Trophy, color: 'text-yellow-600', bg: 'bg-yellow-50' }
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        variants={itemVariants}
                        whileHover={{ y: -5 }}
                        className="bg-white/80 backdrop-blur-xl p-8 rounded-[40px] border border-gray-100 shadow-xl shadow-gray-200/40 flex items-center gap-6"
                    >
                        <div className={`w-16 h-16 ${stat.bg} rounded-[24px] flex items-center justify-center ${stat.color} shadow-inner`}>
                            <stat.icon size={32} />
                        </div>
                        <div>
                            <p className="text-gray-400 text-[10px] font-black uppercase tracking-[0.2em] mb-1">{stat.label}</p>
                            <div className="flex items-baseline gap-2">
                                <p className="text-3xl font-black text-gray-900 tracking-tight">{stat.value}</p>
                                {stat.sub && <span className="text-blue-500 font-bold text-xs">{stat.sub}</span>}
                            </div>
                        </div>
                    </motion.div>
                ))}
            </div>

            {/* Learning Hub Intro */}
            <div className="space-y-8">
                <motion.div variants={itemVariants} className="flex items-center justify-between">
                    <div>
                        <h2 className="text-4xl font-black text-gray-900 tracking-tight">Active Dossiers</h2>
                        <p className="text-gray-500 font-bold text-lg mt-1">Pick up where you left off in your training.</p>
                    </div>
                    <button
                        onClick={() => navigate('/learning')}
                        className="px-6 py-3 bg-gray-50 hover:bg-gray-100 rounded-2xl font-black text-sm text-gray-500 transition-all flex items-center gap-2 group"
                    >
                        Directory <ChevronRight size={18} className="group-hover:translate-x-1 transition-transform" />
                    </button>
                </motion.div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                    {modules.map((mod) => (
                        <motion.button
                            key={mod.id}
                            variants={itemVariants}
                            whileHover={{ y: -12, scale: 1.02 }}
                            onClick={() => navigate(mod.path)}
                            className="bg-white p-8 rounded-[48px] shadow-sm border border-gray-100 group transition-all text-left relative overflow-hidden"
                        >
                            {/* Accent Background */}
                            <div className={`absolute top-0 right-0 w-24 h-24 ${mod.color.replace('bg-', 'bg-')}/5 rounded-bl-[60px] -z-0 transition-all group-hover:w-28 group-hover:h-28`} />

                            <div className={`w-16 h-16 ${mod.color} rounded-2xl flex items-center justify-center text-white mb-8 shadow-2xl shadow-${mod.color.split('-')[1]}-500/30 group-hover:rotate-6 transition-all relative z-10`}>
                                <mod.icon size={32} />
                            </div>

                            <h3 className="text-2xl font-black text-gray-900 mb-3 tracking-tighter relative z-10">{mod.title}</h3>
                            <p className="text-gray-400 text-xs font-black uppercase tracking-widest mb-10 relative z-10">{mod.lessons} Case Files</p>

                            <div className="space-y-3 relative z-10">
                                <div className="flex items-center justify-between text-[10px] font-black uppercase tracking-[0.1em]">
                                    <span className="text-gray-400">Mastery</span>
                                    <span className="text-primary">{mod.progress}%</span>
                                </div>
                                <div className="h-2 bg-gray-50 rounded-full overflow-hidden border border-gray-100/50">
                                    <motion.div
                                        initial={{ width: 0 }}
                                        animate={{ width: `${mod.progress}%` }}
                                        className={`h-full ${mod.color} shadow-[0_0_10px_rgba(0,0,0,0.1)]`}
                                    />
                                </div>
                            </div>
                        </motion.button>
                    ))}
                </div>
            </div>

            {/* Secondary Features Overlay */}
            <motion.div variants={itemVariants} className="grid grid-cols-1 lg:grid-cols-2 gap-10">
                <div className="bg-white/40 backdrop-blur-2xl p-10 rounded-[56px] border border-white/20 shadow-2xl shadow-gray-200/20 relative overflow-hidden">
                    <div className="relative z-10">
                        <h3 className="text-3xl font-black text-gray-900 mb-8 flex items-center gap-4">
                            <Clock className="text-primary" /> Recent Briefings
                        </h3>
                        <div className="space-y-6">
                            {[1].map((_, i) => (
                                <button
                                    key={i}
                                    onClick={() => navigate('/learning')}
                                    className="w-full flex items-center gap-6 p-6 rounded-[32px] hover:bg-white/80 transition-all border border-transparent hover:border-gray-100 group shadow-sm hover:shadow-xl"
                                >
                                    <div className="w-28 h-20 bg-gray-100 rounded-2xl overflow-hidden flex-shrink-0 group-hover:scale-105 transition-transform">
                                        <img src="https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=200" alt="Lesson" className="w-full h-full object-cover" />
                                    </div>
                                    <div className="flex-1">
                                        <h4 className="font-black text-xl text-gray-900 mb-1 tracking-tight">Art. 19: Freedom of Speech</h4>
                                        <p className="text-gray-400 text-[10px] font-black uppercase tracking-[0.2em]">Fundamental Rights • Priority A</p>
                                    </div>
                                    <div className="w-12 h-12 rounded-2xl bg-primary/5 flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all">
                                        <ChevronRight size={24} />
                                    </div>
                                </button>
                            ))}
                        </div>
                    </div>
                </div>

                <div className="bg-[#1a1a2e] p-10 rounded-[56px] text-white flex flex-col justify-between relative overflow-hidden group">
                    {/* Background glow */}
                    <div className="absolute -top-24 -right-24 w-64 h-64 bg-primary/20 rounded-full blur-[100px] group-hover:bg-primary/30 transition-all" />

                    <div className="relative z-10">
                        <div className="w-14 h-14 bg-white/10 rounded-2xl flex items-center justify-center mb-10 border border-white/10">
                            <Star className="text-yellow-400" fill="currentColor" />
                        </div>
                        <h3 className="text-4xl font-black mb-6 tracking-tight leading-none">
                            Daily Intelligence <br />Check
                        </h3>
                        <p className="text-white/60 font-bold text-lg mb-10 leading-relaxed max-w-sm">
                            Validate your legal algorithms against our daily IPC protocols and earn significant XP.
                        </p>
                    </div>

                    <button
                        onClick={() => navigate('/quiz')}
                        className="bg-primary text-white w-full py-6 rounded-[28px] font-black text-xl shadow-2xl shadow-primary/30 hover:scale-[1.02] active:scale-[0.98] transition-all relative z-10 overflow-hidden group/btn"
                    >
                        <span className="relative z-10 flex items-center justify-center gap-3">
                            Initiate Quiz <Zap size={20} fill="currentColor" />
                        </span>
                        <div className="absolute inset-0 bg-white/20 translate-y-full group-hover/btn:translate-y-0 transition-transform duration-300" />
                    </button>
                </div>
            </motion.div>
        </motion.div>
    );
};

export default HomePage;
