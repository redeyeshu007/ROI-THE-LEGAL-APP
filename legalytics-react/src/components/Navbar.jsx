import React from 'react';
import { Bell, Search, User, Sparkles, ChevronDown } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

const Navbar = () => {
    const { user } = useAuth();
    const navigate = useNavigate();

    return (
        <header className="h-24 bg-white/70 backdrop-blur-2xl border-b border-gray-100/50 flex items-center justify-between px-10 sticky top-0 z-30 transition-all">
            {/* Search Bar Group */}
            <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                className="flex items-center gap-4 bg-gray-50/50 hover:bg-white hover:shadow-xl hover:shadow-gray-200/40 px-6 py-3.5 rounded-[24px] w-[450px] border border-gray-100 transition-all group"
            >
                <Search size={18} className="text-gray-400 group-focus-within:text-primary transition-colors" />
                <input
                    type="text"
                    placeholder="Search the legal database..."
                    className="bg-transparent border-none outline-none text-sm w-full font-bold text-gray-700 placeholder:text-gray-400"
                />
                <div className="flex items-center gap-1.5 px-2 py-1 bg-gray-100 rounded-lg text-[9px] font-black text-gray-400 uppercase tracking-widest group-focus-within:hidden">
                    Cmd K
                </div>
            </motion.div>

            {/* Profile & Actions Group */}
            <div className="flex items-center gap-8">
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="flex items-center gap-2"
                >
                    <button className="relative p-3 text-gray-400 hover:text-primary hover:bg-primary/5 rounded-2xl transition-all group">
                        <Bell size={22} />
                        <span className="absolute top-3 right-3 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white group-hover:scale-125 transition-transform"></span>
                    </button>

                    <button className="p-3 text-gray-400 hover:text-primary hover:bg-primary/5 rounded-2xl transition-all">
                        <Sparkles size={22} />
                    </button>
                </motion.div>

                <div className="h-12 w-[1px] bg-gray-100/80"></div>

                <motion.button
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    onClick={() => navigate('/profile')}
                    className="flex items-center gap-4 group bg-gray-50/50 hover:bg-white p-2 pr-6 rounded-[28px] border border-transparent hover:border-gray-100 hover:shadow-xl hover:shadow-gray-200/40 transition-all"
                >
                    <div className="w-14 h-14 rounded-2xl overflow-hidden border-2 border-primary/20 p-0.5 group-hover:border-primary transition-all relative">
                        {user?.photoURL ? (
                            <img src={user.photoURL} alt="Profile" className="w-full h-full object-cover rounded-[14px]" />
                        ) : (
                            <div className="w-full h-full bg-white flex items-center justify-center rounded-[14px]">
                                <User size={24} className="text-primary" />
                            </div>
                        )}
                        <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-emerald-500 border-2 border-white rounded-full"></div>
                    </div>

                    <div className="text-left hidden sm:block">
                        <div className="flex items-center gap-2">
                            <p className="text-sm font-black text-gray-900 leading-none tracking-tight">
                                {user?.displayName || 'Legacy Citizen'}
                            </p>
                            <ChevronDown size={14} className="text-gray-400 group-hover:translate-y-0.5 transition-transform" />
                        </div>
                        <div className="flex items-center gap-2 mt-1.5">
                            <div className="px-2 py-0.5 bg-primary/10 rounded-md text-[9px] font-black text-primary uppercase tracking-[0.1em]">
                                Lvl 12
                            </div>
                            <p className="text-[10px] font-bold text-gray-400">
                                2,450 XP
                            </p>
                        </div>
                    </div>
                </motion.button>
            </div>
        </header>
    );
};

export default Navbar;
