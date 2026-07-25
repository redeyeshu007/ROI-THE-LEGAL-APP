import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Mail, Lock, LogIn, Scale, Gavel, ShieldCheck, FileText, ChevronRight, Sparkles } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const LoginPage = () => {
    const { loginWithGoogle, loginWithEmail } = useAuth();
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [isRegistering, setIsRegistering] = useState(false);

    const handleGoogleLogin = async () => {
        try {
            setLoading(true);
            await loginWithGoogle();
            navigate('/');
        } catch (err) {
            setError('Google login failed. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const handleEmailLogin = async (e) => {
        e.preventDefault();
        try {
            setLoading(true);
            await loginWithEmail(email, password);
            navigate('/');
        } catch (err) {
            setError('Invalid email or password.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-[#0F0F1A] flex flex-col items-center justify-center p-6 relative overflow-hidden font-sans">
            {/* Ambient Background Gradients */}
            <motion.div
                animate={{
                    scale: [1, 1.2, 1],
                    rotate: [0, 90, 0],
                    opacity: [0.3, 0.5, 0.3]
                }}
                transition={{ duration: 20, repeat: Infinity }}
                className="absolute top-[-20%] left-[-10%] w-[60%] h-[60%] bg-purple-600/20 rounded-full blur-[120px]"
            />
            <motion.div
                animate={{
                    scale: [1.2, 1, 1.2],
                    rotate: [90, 0, 90],
                    opacity: [0.2, 0.4, 0.2]
                }}
                transition={{ duration: 15, repeat: Infinity }}
                className="absolute bottom-[-20%] right-[-10%] w-[60%] h-[60%] bg-blue-600/20 rounded-full blur-[120px]"
            />

            {/* Grid Pattern Overlay */}
            <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 pointer-events-none"></div>
            <div className="absolute inset-0 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]"></div>

            <main className="w-full max-w-5xl grid grid-cols-1 lg:grid-cols-2 gap-12 items-center z-10">
                {/* Brand Side */}
                <div className="hidden lg:block space-y-8">
                    <motion.div
                        initial={{ x: -50, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        className="space-y-6"
                    >
                        <div className="w-20 h-20 bg-white/10 backdrop-blur-2xl rounded-[32px] flex items-center justify-center border border-white/20 shadow-2xl shadow-purple-500/20">
                            <Scale size={42} className="text-purple-400" />
                        </div>
                        <h1 className="text-7xl font-black text-white leading-none tracking-tighter">
                            Legalytics <span className="text-purple-500 text-5xl">.</span>
                        </h1>
                        <p className="text-gray-400 text-xl font-bold max-w-md leading-relaxed">
                            The next generation of legal education. Gamified, AI-powered, and built for the future of Indian justice.
                        </p>
                    </motion.div>

                    <motion.div
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: 0.2 }}
                        className="grid grid-cols-2 gap-4"
                    >
                        {[
                            { icon: Sparkles, text: "AI Assistant" },
                            { icon: Gavel, text: "Mock Courts" },
                            { icon: ShieldCheck, text: "Secure Auth" },
                            { icon: FileText, text: "Case Studies" }
                        ].map((item, i) => (
                            <div key={i} className="p-4 bg-white/5 backdrop-blur-md rounded-2xl border border-white/10 flex items-center gap-3">
                                <item.icon size={20} className="text-purple-400" />
                                <span className="text-white font-bold text-sm tracking-wide">{item.text}</span>
                            </div>
                        ))}
                    </motion.div>
                </div>

                {/* Form Side */}
                <motion.div
                    initial={{ scale: 0.9, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    className="relative"
                >
                    {/* Glass Container */}
                    <div className="bg-white/10 backdrop-blur-3xl border border-white/20 rounded-[48px] p-10 md:p-12 shadow-[0_20px_50px_rgba(0,0,0,0.5)]">
                        <div className="mb-10 lg:hidden text-center">
                            <h2 className="text-4xl font-black text-white mb-2">Legalytics</h2>
                        </div>

                        <div className="mb-10 text-center lg:text-left">
                            <h3 className="text-3xl font-black text-white mb-2">
                                {isRegistering ? "Join the Elite" : "Welcome Back"}
                            </h3>
                            <p className="text-gray-400 font-bold">
                                {isRegistering ? "Start your legal journey today." : "Continue where you left off."}
                            </p>
                        </div>

                        <form onSubmit={handleEmailLogin} className="space-y-6">
                            <div className="space-y-2">
                                <label className="text-xs font-black text-gray-400 uppercase tracking-[0.2em] ml-1">Email Domain</label>
                                <div className="relative">
                                    <Mail className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
                                    <input
                                        type="email"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        placeholder="advocate@legalytics.com"
                                        className="w-full bg-black/40 border border-white/10 focus:border-purple-500/50 py-5 pl-14 pr-6 rounded-3xl text-white font-bold outline-none transition-all placeholder:text-gray-600"
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-xs font-black text-gray-400 uppercase tracking-[0.2em] ml-1">Secure Pass</label>
                                <div className="relative">
                                    <Lock className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
                                    <input
                                        type="password"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder="••••••••"
                                        className="w-full bg-black/40 border border-white/10 focus:border-purple-500/50 py-5 pl-14 pr-6 rounded-3xl text-white font-bold outline-none transition-all placeholder:text-gray-600"
                                    />
                                </div>
                            </div>

                            {error && (
                                <motion.p
                                    initial={{ opacity: 0, y: -10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    className="text-red-400 text-sm font-bold bg-red-400/10 p-3 rounded-xl border border-red-400/20"
                                >
                                    {error}
                                </motion.p>
                            )}

                            <button
                                type="submit"
                                disabled={loading}
                                className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white py-5 rounded-3xl font-black text-lg shadow-2xl shadow-purple-600/30 hover:shadow-purple-600/50 hover:scale-[1.01] active:scale-[0.99] transition-all disabled:opacity-50 flex items-center justify-center gap-3"
                            >
                                {loading ? "Authorizing..." : (isRegistering ? "Create Dossier" : "Access Hub")}
                                <ChevronRight size={24} />
                            </button>
                        </form>

                        <div className="relative my-10 flex items-center justify-center">
                            <div className="w-full border-t border-white/10"></div>
                            <span className="absolute bg-[#1a1a2e] px-4 text-xs font-black text-gray-500 uppercase tracking-[0.3em]">Neural Bridge</span>
                        </div>

                        <button
                            onClick={handleGoogleLogin}
                            disabled={loading}
                            className="w-full bg-white/5 border border-white/10 py-5 rounded-3xl font-bold text-white flex items-center justify-center gap-4 hover:bg-white/10 transition-all active:scale-[0.98]"
                        >
                            <img src="https://www.google.com/favicon.ico" className="w-6 h-6 grayscale brightness-200" alt="" />
                            Secure Google Entry
                        </button>

                        <div className="mt-10 text-center">
                            <button
                                onClick={() => setIsRegistering(!isRegistering)}
                                className="text-gray-400 font-bold text-sm hover:text-white transition-colors"
                            >
                                {isRegistering ? "Already a citizen? Sign In" : "New to the platform? Join Now"}
                            </button>
                        </div>
                    </div>
                </motion.div>
            </main>

            {/* Footer Tag */}
            <div className="absolute bottom-6 text-gray-600 font-black text-[10px] uppercase tracking-[0.5em] opacity-40">
                Encrypted Session • ROI Legal Technologies • 2026
            </div>
        </div>
    );
};

export default LoginPage;
