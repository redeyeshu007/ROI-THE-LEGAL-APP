import React, { useState, useEffect } from 'react';
import {
    Users,
    ShieldCheck,
    AlertTriangle,
    ChevronLeft,
    CheckCircle2,
    Flame,
    ArrowRight
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const CivicAssemblyGame = () => {
    const navigate = useNavigate();
    const [gameState, setGameState] = useState('intro'); // intro, simulation, result
    const [energy, setEnergy] = useState(50);
    const [peaceful, setPeaceful] = useState(100);
    const [currentEvent, setCurrentEvent] = useState(0);

    const events = [
        {
            title: "The Gathering",
            desc: "A large crowd has gathered at the designated protest site. Some individuals are starting to shout aggressively.",
            options: [
                { text: "Call for calm and peaceful slogans", energy: -10, peaceful: 10, legal: "Art 19(1)(b): Right to assemble peaceably and without arms." },
                { text: "Encourage louder, high-energy chanting", energy: 20, peaceful: -5, legal: "Reasonable restrictions apply if public order is threatened." }
            ]
        },
        {
            title: "Police Interaction",
            desc: "Authorities ask the assembly to move 50 meters back to keep the main road clear.",
            options: [
                { text: "Comply and move the assembly", energy: -5, peaceful: 15, legal: "State can impose reasonable restrictions for public order." },
                { text: "Refuse to move, claiming right to site", energy: 15, peaceful: -20, legal: "Obstruction of public way may lead to Section 141 IPC (Unlawful Assembly)." }
            ]
        }
    ];

    const handleDecision = (opt) => {
        setEnergy(prev => Math.min(100, Math.max(0, prev + opt.energy)));
        setPeaceful(prev => Math.min(100, Math.max(0, prev + opt.peaceful)));

        if (currentEvent + 1 < events.length) {
            setCurrentEvent(prev => prev + 1);
        } else {
            setGameState('result');
        }
    };

    return (
        <div className="max-w-4xl mx-auto h-[calc(100vh-160px)] flex flex-col items-center justify-center p-6">
            <AnimatePresence mode="wait">
                {gameState === 'intro' && (
                    <motion.div
                        key="intro"
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="text-center space-y-8 bg-white p-12 rounded-[50px] border border-gray-100 shadow-2xl"
                    >
                        <div className="w-24 h-24 bg-emerald-50 rounded-[32px] mx-auto flex items-center justify-center text-emerald-500 shadow-lg">
                            <Users size={48} />
                        </div>
                        <div className="space-y-4">
                            <h1 className="text-4xl font-black text-gray-900">Civic Assembly Sim</h1>
                            <p className="text-gray-500 font-bold max-w-sm mx-auto leading-relaxed">
                                Exercise your constitutional right to protest! Balance crowd energy with peaceful conduct to ensure your assembly stays legal.
                            </p>
                        </div>
                        <button
                            onClick={() => setGameState('simulation')}
                            className="px-12 py-5 premium-gradient text-white rounded-[24px] font-black text-xl shadow-xl hover:scale-105 transition-transform"
                        >
                            Start Assembly
                        </button>
                    </motion.div>
                )}

                {gameState === 'simulation' && (
                    <motion.div
                        key="sim"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="w-full h-full flex flex-col gap-10"
                    >
                        <div className="grid grid-cols-2 gap-6">
                            <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm space-y-4">
                                <div className="flex items-center justify-between">
                                    <span className="text-xs font-black uppercase text-gray-400">Crowd Energy</span>
                                    <Flame size={18} className="text-orange-500" />
                                </div>
                                <div className="h-4 bg-gray-100 rounded-full overflow-hidden">
                                    <motion.div animate={{ width: `${energy}%` }} className="h-full bg-orange-500" />
                                </div>
                            </div>
                            <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm space-y-4">
                                <div className="flex items-center justify-between">
                                    <span className="text-xs font-black uppercase text-gray-400">Peaceful Conduct</span>
                                    <ShieldCheck size={18} className="text-emerald-500" />
                                </div>
                                <div className="h-4 bg-gray-100 rounded-full overflow-hidden">
                                    <motion.div animate={{ width: `${peaceful}%` }} className="h-full bg-emerald-500" />
                                </div>
                            </div>
                        </div>

                        <div className="flex-1 flex flex-col items-center justify-center space-y-12">
                            <div className="relative">
                                {/* Visual Assembly Indicator */}
                                <div className="flex gap-4 items-end h-32">
                                    {[...Array(10)].map((_, i) => (
                                        <motion.div
                                            key={i}
                                            animate={{ height: [`${30 + Math.random() * 20}%`, `${60 + energy / 2}%`, `${30 + Math.random() * 20}%`] }}
                                            transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.1 }}
                                            className={`w-6 rounded-t-xl ${peaceful < 40 ? 'bg-red-500' : 'bg-primary'}`}
                                        />
                                    ))}
                                </div>
                            </div>

                            <div className="bg-white p-10 rounded-[40px] border border-gray-100 shadow-xl max-w-2xl w-full text-center space-y-6">
                                <h3 className="text-2xl font-black text-gray-900">{events[currentEvent].title}</h3>
                                <p className="text-gray-500 font-bold text-lg leading-relaxed">
                                    {events[currentEvent].desc}
                                </p>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-8">
                                    {events[currentEvent].options.map((opt, i) => (
                                        <button
                                            key={i}
                                            onClick={() => handleDecision(opt)}
                                            className="p-6 rounded-3xl border-2 border-gray-100 font-black text-gray-700 hover:border-primary hover:text-primary hover:bg-primary/5 transition-all text-sm leading-tight"
                                        >
                                            {opt.text}
                                        </button>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </motion.div>
                )}

                {gameState === 'result' && (
                    <motion.div
                        key="result"
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="text-center space-y-10 bg-white p-16 rounded-[60px] border border-gray-100 shadow-2xl max-w-xl"
                    >
                        {peaceful > 50 ? (
                            <>
                                <div className="w-24 h-24 bg-emerald-100 text-emerald-600 rounded-full mx-auto flex items-center justify-center">
                                    <CheckCircle2 size={64} />
                                </div>
                                <h2 className="text-4xl font-black text-gray-900">Lawful Assembly!</h2>
                                <p className="text-gray-500 font-bold text-lg italic">
                                    "You successfully exercised your Article 19(1)(b) rights while maintaining public order."
                                </p>
                            </>
                        ) : (
                            <>
                                <div className="w-24 h-24 bg-red-100 text-red-600 rounded-full mx-auto flex items-center justify-center">
                                    <AlertTriangle size={64} />
                                </div>
                                <h2 className="text-4xl font-black text-gray-900">Assembly Dissolved</h2>
                                <p className="text-gray-500 font-bold text-lg italic">
                                    "The assembly became volatile. Authorities may issue a dispersal order under Section 129 CrPC."
                                </p>
                            </>
                        )}

                        <button
                            onClick={() => navigate('/dashboard')}
                            className="w-full py-5 premium-gradient text-white rounded-3xl font-black shadow-xl"
                        >
                            Continue Journey
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default CivicAssemblyGame;
