import React from 'react';
import { Trophy, Medal, Star, Target, ChevronRight, User } from 'lucide-react';
import { motion } from 'framer-motion';

const LeaderboardPage = () => {
    const topUsers = [
        { id: 1, name: 'Sriram Gandhi', xp: '15,450', level: 45, rank: 1, avatar: 'https://i.pravatar.cc/150?u=sriram' },
        { id: 2, name: 'Ananya Sharma', xp: '12,200', level: 38, rank: 2, avatar: 'https://i.pravatar.cc/150?u=ananya' },
        { id: 3, name: 'Rohan Verma', xp: '10,800', level: 32, rank: 3, avatar: 'https://i.pravatar.cc/150?u=rohan' },
    ];

    const otherUsers = [
        { id: 4, name: 'Priya Patel', xp: '8,450', level: 28, rank: 4 },
        { id: 5, name: 'Arjun Das', xp: '7,900', level: 25, rank: 5 },
        { id: 6, name: 'Sneha Rao', xp: '7,200', level: 22, rank: 6 },
        { id: 7, name: 'Vikram Singh', xp: '6,800', level: 20, rank: 7 },
        { id: 8, name: 'Meera Iyer', xp: '5,400', level: 18, rank: 8 },
    ];

    return (
        <div className="max-w-5xl mx-auto space-y-12">
            <div className="text-center">
                <h1 className="text-4xl font-black text-gray-900 mb-2">Global Rankings</h1>
                <p className="text-gray-500 font-bold text-lg">Top Legal Scholars of the Month</p>
            </div>

            {/* Podium */}
            <div className="flex flex-col md:flex-row items-end justify-center gap-6 pt-10 px-6">
                {/* 2nd Place */}
                <div className="order-2 md:order-1 flex flex-col items-center">
                    <div className="relative mb-4">
                        <div className="w-20 h-20 rounded-full border-4 border-slate-300 overflow-hidden shadow-lg">
                            <img src={topUsers[1].avatar} alt="" className="w-full h-full object-cover" />
                        </div>
                        <div className="absolute -top-2 -right-2 w-8 h-8 bg-slate-300 rounded-full flex items-center justify-center text-slate-700 font-bold text-xs ring-4 ring-white">2</div>
                    </div>
                    <div className="bg-white px-6 py-8 rounded-t-[32px] border border-gray-100 shadow-sm w-48 text-center h-48 flex flex-col justify-end">
                        <h3 className="font-black text-gray-900 text-sm mb-1">{topUsers[1].name}</h3>
                        <p className="text-primary font-black text-lg">{topUsers[1].xp} XP</p>
                    </div>
                </div>

                {/* 1st Place */}
                <div className="order-1 md:order-2 flex flex-col items-center -mt-10">
                    <Trophy className="text-yellow-400 mb-2 animate-bounce" size={40} fill="currentColor" />
                    <div className="relative mb-6">
                        <div className="w-28 h-28 rounded-full border-4 border-yellow-400 overflow-hidden shadow-2xl">
                            <img src={topUsers[0].avatar} alt="" className="w-full h-full object-cover" />
                        </div>
                        <div className="absolute -top-2 -right-2 w-10 h-10 bg-yellow-400 rounded-full flex items-center justify-center text-white font-bold text-lg ring-4 ring-white shadow-xl shadow-yellow-400/20">1</div>
                    </div>
                    <div className="bg-white px-8 py-10 rounded-t-[40px] border border-gray-100 shadow-xl w-56 text-center h-64 flex flex-col justify-end ring-4 ring-primary/5">
                        <h3 className="font-black text-gray-900 text-lg mb-1">{topUsers[0].name}</h3>
                        <p className="text-primary font-black text-2xl">{topUsers[0].xp} XP</p>
                    </div>
                </div>

                {/* 3rd Place */}
                <div className="order-3 flex flex-col items-center">
                    <div className="relative mb-4">
                        <div className="w-20 h-20 rounded-full border-4 border-orange-400 overflow-hidden shadow-lg">
                            <img src={topUsers[2].avatar} alt="" className="w-full h-full object-cover" />
                        </div>
                        <div className="absolute -top-2 -right-2 w-8 h-8 bg-orange-400 rounded-full flex items-center justify-center text-white font-bold text-xs ring-4 ring-white">3</div>
                    </div>
                    <div className="bg-white px-6 py-8 rounded-t-[32px] border border-gray-100 shadow-sm w-48 text-center h-40 flex flex-col justify-end">
                        <h3 className="font-black text-gray-900 text-sm mb-1">{topUsers[2].name}</h3>
                        <p className="text-primary font-black text-lg">{topUsers[2].xp} XP</p>
                    </div>
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-[40px] border border-gray-100 shadow-sm overflow-hidden mb-10">
                <div className="p-8 border-b border-gray-50 bg-gray-50/30 flex items-center justify-between">
                    <h3 className="text-xl font-black text-gray-900">Rankings Hub</h3>
                    <div className="flex items-center gap-2 text-primary font-black text-xs uppercase tracking-widest bg-white px-4 py-2 rounded-full border border-gray-100 shadow-sm">
                        <Star size={14} fill="currentColor" /> National Leaderboard
                    </div>
                </div>

                <div className="divide-y divide-gray-50">
                    {otherUsers.map((user, idx) => (
                        <motion.div
                            key={user.id}
                            whileHover={{ bg: 'rgb(249 250 251)' }}
                            className="p-6 flex items-center gap-6"
                        >
                            <span className="w-8 font-black text-gray-400 text-lg tabular-nums">#{user.rank}</span>
                            <div className="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center text-gray-400 flex-shrink-0">
                                <User size={24} />
                            </div>
                            <div className="flex-1">
                                <h4 className="font-black text-gray-900 leading-none mb-1">{user.name}</h4>
                                <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Level {user.level}</p>
                            </div>
                            <div className="text-right">
                                <p className="text-lg font-black text-primary leading-none">{user.xp} XP</p>
                                <div className="flex items-center justify-end gap-1 text-[10px] font-black uppercase tracking-widest text-emerald-500 mt-1">
                                    <Target size={10} /> {user.rank < 6 ? 'Master' : 'Rising'}
                                </div>
                            </div>
                            <ChevronRight size={20} className="text-gray-200" />
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default LeaderboardPage;
