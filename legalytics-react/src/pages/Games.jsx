import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Gamepad2,
    Car,
    Search,
    Users,
    ChevronRight,
    Play
} from 'lucide-react';
import { motion } from 'framer-motion';

const Games = () => {
    const navigate = useNavigate();

    const gameList = [
        {
            id: 'match',
            title: 'Match the Law',
            desc: 'Drag and drop term definitions to match the correct Indian Laws.',
            icon: Search,
            color: 'bg-indigo-500',
            path: '/games/match'
        },
        {
            id: 'runner',
            title: 'Traffic Runner',
            desc: 'High-speed avoidance game where you learn traffic rules on the go.',
            icon: Car,
            color: 'bg-pink-500',
            path: '/games/runner'
        },
        {
            id: 'assembly',
            title: 'Civic Assembly',
            desc: 'Manage a peaceful protest and learn your assembly rights.',
            icon: Users,
            color: 'bg-emerald-500',
            path: '/games/assembly'
        }
    ];

    return (
        <div className="max-w-6xl mx-auto space-y-12">
            <div>
                <h1 className="text-4xl font-black text-gray-900 mb-2">Game Arcade</h1>
                <p className="text-gray-500 font-bold text-lg">Interactive legal simulations and challenges</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {gameList.map((game, idx) => (
                    <motion.div
                        key={game.id}
                        whileHover={{ y: -8 }}
                        className="group bg-white p-8 rounded-[40px] shadow-sm border border-gray-100 flex flex-col h-full"
                    >
                        <div className={`w-16 h-16 ${game.color} rounded-2xl flex items-center justify-center text-white mb-8 shadow-xl shadow-${game.color.split('-')[1]}-500/20 group-hover:rotate-12 transition-transform`}>
                            <game.icon size={32} />
                        </div>

                        <div className="flex-1">
                            <h3 className="text-2xl font-black text-gray-900 mb-3">{game.title}</h3>
                            <p className="text-gray-500 font-semibold text-sm leading-relaxed mb-10">
                                {game.desc}
                            </p>
                        </div>

                        <button
                            onClick={() => navigate(game.path)}
                            className="w-full py-4 bg-gray-900 text-white rounded-2xl font-black flex items-center justify-center gap-3 hover:bg-primary transition-colors shadow-lg shadow-gray-200"
                        >
                            Play Now <Play size={18} fill="currentColor" />
                        </button>
                    </motion.div>
                ))}
            </div>

            <div className="bg-white p-10 rounded-[40px] border border-gray-100 shadow-sm flex flex-col md:flex-row items-center gap-10">
                <div className="w-24 h-24 bg-yellow-50 rounded-[32px] flex items-center justify-center text-yellow-500 flex-shrink-0">
                    <Gamepad2 size={48} />
                </div>
                <div className="flex-1 text-center md:text-left">
                    <h3 className="text-2xl font-black text-gray-900 mb-2">Practice & Earn XP</h3>
                    <p className="text-gray-500 font-medium">All games contribute to your global leaderboard ranking. Play daily to maintain your streak!</p>
                </div>
                <button className="px-10 py-4 bg-gray-50 text-gray-400 font-black rounded-2xl cursor-not-allowed">
                    Coming Soon: Quiz Battle
                </button>
            </div>
        </div>
    );
};

export default Games;
