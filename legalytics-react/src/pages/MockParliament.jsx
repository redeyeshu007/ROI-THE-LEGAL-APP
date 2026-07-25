import React, { useState } from 'react';
import {
    Users,
    Gavel,
    ChevronRight,
    Award,
    MessageSquare,
    ShieldCheck,
    ChevronLeft,
    ArrowRight
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const MockParliament = () => {
    const navigate = useNavigate();
    const [step, setStep] = useState('intro'); // intro, role, scenario, action, result
    const [selectedRole, setSelectedRole] = useState(null);

    const roles = [
        { id: 'speaker', title: 'Speaker of the House', icon: Gavel, desc: 'Maintain order and ensure constitutional procedures are followed.' },
        { id: 'opposition', title: 'Leader of Opposition', icon: MessageSquare, desc: 'Question the government and represent alternative views.' },
        { id: 'mp', title: 'Member of Parliament', icon: Users, desc: 'Debate on bills and vote on key legislative changes.' }
    ];

    const scenarios = [
        {
            id: 1,
            title: 'Digital Privacy Act',
            issue: 'A new bill proposing mandatory identification for all social media users.',
            law: 'Art 21 - Right to Privacy'
        }
    ];

    return (
        <div className="max-w-5xl mx-auto min-h-[calc(100vh-160px)] flex flex-col items-center justify-center py-10">
            <AnimatePresence mode="wait">

                {step === 'intro' && (
                    <motion.div
                        key="intro"
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -30 }}
                        className="text-center space-y-10"
                    >
                        <div className="w-24 h-24 premium-gradient rounded-[32px] mx-auto flex items-center justify-center text-white shadow-2xl shadow-primary/30">
                            <Users size={48} />
                        </div>
                        <div className="space-y-4">
                            <h1 className="text-5xl font-black text-gray-900 leading-tight">Mock Parliament</h1>
                            <p className="text-gray-500 font-bold text-xl max-w-xl mx-auto">
                                Step into the temple of democracy. Debate, decide, and shape the laws of the nation in this realistic simulation.
                            </p>
                        </div>
                        <button
                            onClick={() => setStep('role')}
                            className="px-12 py-5 premium-gradient text-white rounded-[30px] font-black text-xl shadow-xl hover:scale-105 transition-transform flex items-center gap-4 mx-auto"
                        >
                            Enter Session <ArrowRight size={24} />
                        </button>
                    </motion.div>
                )}

                {step === 'role' && (
                    <motion.div
                        key="role"
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="w-full space-y-12"
                    >
                        <div className="text-center">
                            <h2 className="text-3xl font-black text-gray-900 mb-2">Choose Your Role</h2>
                            <p className="text-gray-500 font-bold">Each role has different responsibilities during the session.</p>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                            {roles.map((role) => (
                                <button
                                    key={role.id}
                                    onClick={() => { setSelectedRole(role); setStep('scenario'); }}
                                    className="bg-white p-8 rounded-[44px] border border-gray-100 shadow-sm hover:border-primary/30 hover:shadow-xl transition-all group text-left flex flex-col justify-between"
                                >
                                    <div className="w-16 h-16 bg-gray-50 rounded-2xl flex items-center justify-center text-gray-400 group-hover:bg-primary/10 group-hover:text-primary transition-all mb-8">
                                        <role.icon size={32} />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-black text-gray-900 mb-3">{role.title}</h3>
                                        <p className="text-gray-400 font-semibold text-sm leading-relaxed">{role.desc}</p>
                                    </div>
                                </button>
                            ))}
                        </div>
                    </motion.div>
                )}

                {step === 'scenario' && (
                    <motion.div
                        key="scenario"
                        initial={{ opacity: 0, x: 50 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="w-full max-w-2xl bg-white p-12 rounded-[50px] border border-gray-100 shadow-2xl space-y-10"
                    >
                        <div className="flex items-center gap-4 mb-2">
                            <div className="px-4 py-1.5 bg-primary/10 text-primary rounded-full text-[10px] font-black uppercase tracking-widest">Ongoing Session</div>
                            <span className="text-gray-300">|</span>
                            <span className="text-xs font-bold text-gray-400 italic">Bill #2024-B-09</span>
                        </div>

                        <h2 className="text-4xl font-black text-gray-900 leading-tight">
                            {scenarios[0].title}
                        </h2>

                        <div className="bg-gray-50 p-8 rounded-[32px] border border-gray-100">
                            <p className="text-gray-600 font-bold text-lg leading-relaxed italic">
                                "{scenarios[0].issue}"
                            </p>
                        </div>

                        <div className="flex items-center gap-4 p-4 bg-emerald-50 rounded-2xl border border-emerald-100">
                            <ShieldCheck className="text-emerald-500" />
                            <p className="text-emerald-700 font-black text-sm">Legal Context: {scenarios[0].law}</p>
                        </div>

                        <div className="flex gap-4">
                            <button
                                onClick={() => setStep('role')}
                                className="flex-1 bg-gray-100 text-gray-400 py-5 rounded-3xl font-black"
                            >
                                Change Role
                            </button>
                            <button
                                onClick={() => setStep('action')}
                                className="flex-1 premium-gradient text-white py-5 rounded-3xl font-black shadow-xl"
                            >
                                Begin Debate
                            </button>
                        </div>
                    </motion.div>
                )}

                {step === 'action' && (
                    <motion.div
                        key="action"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="w-full space-y-10"
                    >
                        <div className="bg-gray-900 p-10 rounded-[50px] text-white shadow-2xl relative overflow-hidden">
                            <div className="relative z-10 flex flex-col md:flex-row gap-10 items-center">
                                <div className="w-32 h-32 rounded-full border-4 border-white/20 overflow-hidden flex-shrink-0">
                                    <img src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200" alt="Speaker" className="w-full h-full object-cover" />
                                </div>
                                <div className="space-y-4 flex-1">
                                    <div className="flex items-center gap-2">
                                        <Gavel size={18} className="text-yellow-400" />
                                        <span className="text-white/60 font-black text-xs uppercase tracking-widest text-[10px]">Speaker Intervening</span>
                                    </div>
                                    <p className="text-2xl font-black leading-tight italic">
                                        "Members of the house! This bill relates to fundamental privacy. How does the {selectedRole.id === 'opposition' ? 'Government' : 'Opposition'} plan to address the technological impact?"
                                    </p>
                                </div>
                            </div>
                            {/* Soundwave animation effect */}
                            <div className="absolute bottom-0 left-0 right-0 h-1 flex items-end gap-1 px-8">
                                {[...Array(20)].map((_, i) => (
                                    <motion.div
                                        key={i}
                                        animate={{ height: [4, 12, 4] }}
                                        transition={{ duration: 1, repeat: Infinity, delay: i * 0.1 }}
                                        className="flex-1 bg-primary/40 rounded-t-sm"
                                    />
                                ))}
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-4xl mx-auto">
                            <button
                                onClick={() => setStep('intro')}
                                className="p-8 bg-white rounded-[40px] border border-gray-100 shadow-sm text-left hover:border-primary/30 transition-all flex items-center justify-between group"
                            >
                                <div>
                                    <span className="block text-[10px] font-black uppercase tracking-widest text-primary mb-2">Option A</span>
                                    <p className="text-lg font-black text-gray-900">Uphold Right to Privacy</p>
                                </div>
                                <ChevronRight className="text-gray-200 group-hover:text-primary transition-colors" />
                            </button>
                            <button
                                onClick={() => setStep('intro')}
                                className="p-8 bg-white rounded-[40px] border border-gray-100 shadow-sm text-left hover:border-primary/30 transition-all flex items-center justify-between group"
                            >
                                <div>
                                    <span className="block text-[10px] font-black uppercase tracking-widest text-primary mb-2">Option B</span>
                                    <p className="text-lg font-black text-gray-900">Prioritize National Security</p>
                                </div>
                                <ChevronRight className="text-gray-200 group-hover:text-primary transition-colors" />
                            </button>
                        </div>
                    </motion.div>
                )}

            </AnimatePresence>
        </div>
    );
};

export default MockParliament;
