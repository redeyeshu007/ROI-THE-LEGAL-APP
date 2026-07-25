import React, { useState, useEffect, useRef } from 'react';
import {
    Send,
    Mic,
    Settings,
    RotateCcw,
    X,
    Languages,
    Volume2,
    VolumeX,
    PlusCircle,
    Gavel,
    ShieldCheck,
    Scale
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { callGroq } from '../services/groq';

const Chatbot = () => {
    const [mode, setMode] = useState('chat'); // 'chat' or 'voice'
    const [messages, setMessages] = useState([]);
    const [input, setInput] = useState('');
    const [lang, setLang] = useState('English');
    const [isTyping, setIsTyping] = useState(false);
    const [isMuted, setIsMuted] = useState(false);
    const scrollRef = useRef(null);

    const languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Marathi', 'Malayalam', 'Kannada', 'Bengali'];

    const quickSuggestions = {
        'English': ['Explain Article 19', 'What is Cyber Defamation?', 'Rights on arrest'],
        'Hindi': ['अनुच्छेद 19 समझाएं', 'साइबर मानहानि क्या है?', 'गिरफ्तारी पर अधिकार'],
        'Tamil': ['பிரிவு 19-ஐ விளக்குக', 'சைபர் அவதூறு என்றால் என்ன?', 'கைது செய்யப்படும் உரிமைகள்']
    };

    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages, isTyping]);

    const speak = (jsonText) => {
        if (isMuted) return;
        const synth = window.speechSynthesis;
        const utterance = new SpeechSynthesisUtterance(jsonText);
        utterance.lang = lang === 'English' ? 'en-IN' : 'hi-IN'; // Simplified
        synth.speak(utterance);
    };

    const handleSend = async (text = input) => {
        if (!text.trim()) return;

        const userMsg = { role: 'user', content: text };
        setMessages(prev => [...prev, userMsg]);
        setInput('');
        setIsTyping(true);

        try {
            const response = await callGroq(text, mode, lang, messages);
            const aiMsg = { role: 'assistant', content: response };
            setMessages(prev => [...prev, aiMsg]);
            if (mode === 'voice') speak(response);
        } catch (err) {
            setMessages(prev => [...prev, { role: 'assistant', content: 'Sorry, I am having trouble connecting. Please try again.' }]);
        } finally {
            setIsTyping(false);
        }
    };

    return (
        <div className="max-w-4xl mx-auto h-[calc(100vh-140px)] flex flex-col gap-6">
            {/* Header Controls */}
            <div className="flex flex-wrap items-center justify-between gap-4">
                <div className="flex bg-white p-1 rounded-2xl border border-gray-100 shadow-sm">
                    <button
                        onClick={() => setMode('chat')}
                        className={`px-6 py-2 rounded-xl text-sm font-black transition-all ${mode === 'chat' ? 'bg-primary text-white shadow-lg shadow-primary/20' : 'text-gray-400 hover:text-primary'}`}
                    >
                        NEEDHi (Chat)
                    </button>
                    <button
                        onClick={() => setMode('voice')}
                        className={`px-6 py-2 rounded-xl text-sm font-black transition-all ${mode === 'voice' ? 'bg-primary text-white shadow-lg shadow-primary/20' : 'text-gray-400 hover:text-primary'}`}
                    >
                        VIDDHI (Voice)
                    </button>
                </div>

                <div className="flex items-center gap-3">
                    <div className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl border border-gray-100 shadow-sm">
                        <Languages size={18} className="text-primary" />
                        <select
                            value={lang}
                            onChange={(e) => setLang(e.target.value)}
                            className="outline-none bg-transparent text-sm font-black text-gray-700 cursor-pointer"
                        >
                            {languages.map(l => <option key={l} value={l}>{l}</option>)}
                        </select>
                    </div>

                    <button
                        onClick={() => setMessages([])}
                        className="p-3 bg-white rounded-2xl border border-gray-100 shadow-sm text-gray-400 hover:text-red-500 transition-colors"
                    >
                        <RotateCcw size={20} />
                    </button>
                </div>
            </div>

            {mode === 'chat' ? (
                <div className="flex-1 glass-card flex flex-col overflow-hidden relative border-none shadow-2xl shadow-primary/5 bg-white/80">
                    {/* Chat Messages */}
                    <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 scroll-smooth">
                        {messages.length === 0 && (
                            <div className="h-full flex flex-col items-center justify-center text-center p-10">
                                <div className="w-20 h-20 bg-primary/10 rounded-3xl flex items-center justify-center text-primary mb-6">
                                    <Scale size={40} />
                                </div>
                                <h3 className="text-2xl font-black text-gray-900 mb-2">I am NEEDHi</h3>
                                <p className="text-gray-500 font-semibold max-w-sm">
                                    Your dedicated legal assistant. Ask me anything about the Indian Law, Fundamental Rights, or IPC.
                                </p>
                            </div>
                        )}

                        {messages.map((msg, idx) => (
                            <motion.div
                                key={idx}
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                            >
                                <div className={`max-w-[80%] p-5 rounded-[24px] shadow-sm font-medium leading-relaxed ${msg.role === 'user'
                                        ? 'bg-primary text-white rounded-tr-none'
                                        : 'bg-gray-50 text-gray-800 rounded-tl-none border border-gray-100'
                                    }`}>
                                    <p className="whitespace-pre-wrap">{msg.content}</p>
                                </div>
                            </motion.div>
                        ))}

                        {isTyping && (
                            <div className="flex justify-start">
                                <div className="bg-gray-50 p-5 rounded-[24px] rounded-tl-none border border-gray-100 flex gap-1 items-center">
                                    <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce"></span>
                                    <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce delay-75"></span>
                                    <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce delay-150"></span>
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Input Area */}
                    <div className="p-6 bg-white/50 backdrop-blur-md border-t border-gray-100">
                        <div className="flex flex-wrap gap-2 mb-4">
                            {(quickSuggestions[lang] || quickSuggestions['English']).map((s, i) => (
                                <button
                                    key={i}
                                    onClick={() => handleSend(s)}
                                    className="px-4 py-2 bg-primary/5 text-primary rounded-full text-xs font-black border border-primary/10 hover:bg-primary hover:text-white transition-all shadow-sm"
                                >
                                    {s}
                                </button>
                            ))}
                        </div>

                        <div className="relative group flex items-center gap-3">
                            <input
                                type="text"
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                                placeholder={`Ask NEEDHi in ${lang}...`}
                                className="flex-1 bg-white border border-gray-100 py-4 px-6 rounded-2xl outline-none font-semibold focus:border-primary/30 shadow-sm transition-all"
                            />
                            <button
                                onClick={() => handleSend()}
                                disabled={!input.trim()}
                                className="p-4 premium-gradient text-white rounded-2xl shadow-lg shadow-primary/20 hover:scale-105 active:scale-95 transition-all disabled:opacity-50"
                            >
                                <Send size={24} />
                            </button>
                        </div>
                    </div>
                </div>
            ) : (
                <div className="flex-1 flex flex-col items-center justify-center space-y-12">
                    {/* Circular Voice Orb */}
                    <motion.div
                        animate={{
                            scale: isTyping ? [1, 1.1, 1] : 1,
                            boxShadow: isTyping
                                ? ["0 0 0 0px rgba(108, 58, 237, 0.4)", "0 0 0 40px rgba(108, 58, 237, 0)", "0 0 0 0px rgba(108, 58, 237, 0)"]
                                : "none"
                        }}
                        transition={{ duration: 2, repeat: Infinity }}
                        className="w-48 h-48 premium-gradient rounded-full flex items-center justify-center text-white relative z-10 shadow-3xl shadow-primary/40"
                    >
                        <Mic size={64} className={isTyping ? "animate-pulse" : ""} />

                        {/* Pulsing rings */}
                        <div className="absolute inset-0 rounded-full border-4 border-white/20 animate-ping"></div>
                    </motion.div>

                    <div className="text-center space-y-4 max-w-md">
                        <h2 className="text-3xl font-black text-gray-900 leading-tight">I am listening...</h2>
                        <p className="text-gray-500 font-semibold leading-relaxed">
                            Ask me your legal questions verbally, and I'll explain them to you clearly in {lang}.
                        </p>
                    </div>

                    <div className="flex items-center gap-6">
                        <button
                            onClick={() => setIsMuted(!isMuted)}
                            className={`p-5 rounded-[24px] border border-gray-100 shadow-sm transition-all ${isMuted ? 'bg-red-50 text-red-500' : 'bg-white text-primary hover:bg-gray-50'}`}
                        >
                            {isMuted ? <VolumeX size={28} /> : <Volume2 size={28} />}
                        </button>
                        <button className="px-10 py-5 premium-gradient text-white rounded-[24px] font-black text-lg shadow-xl shadow-primary/30 hover:scale-105 active:scale-95 transition-all">
                            Tap to Speak
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Chatbot;
