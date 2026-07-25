import React, { useState } from 'react';
import {
    Trophy,
    CheckCircle2,
    XCircle,
    RotateCcw,
    ChevronRight,
    Flame,
    Target,
    ChevronLeft
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const QuizPage = () => {
    const navigate = useNavigate();
    const [gameState, setGameState] = useState('selection'); // selection, playing, results
    const [difficulty, setDifficulty] = useState(null);
    const [currentQuestion, setCurrentQuestion] = useState(0);
    const [score, setScore] = useState(0);
    const [selectedAnswer, setSelectedAnswer] = useState(null);
    const [isAnswered, setIsAnswered] = useState(false);

    const questions = {
        easy: [
            {
                q: "Which article of the Indian Constitution guarantees the Right to Equality?",
                options: ["Article 14", "Article 21", "Article 32", "Article 19"],
                a: 0
            },
            {
                q: "What is the minimum age to vote in India?",
                options: ["16", "18", "21", "25"],
                a: 1
            },
            {
                q: "Who is known as the Father of the Indian Constitution?",
                options: ["Mahatma Gandhi", "Jawaharlal Nehru", "B.R. Ambedkar", "Sardar Patel"],
                a: 2
            }
        ],
        hard: [
            {
                q: "Which Supreme Court case established the 'Basic Structure Doctrine'?",
                options: ["Golaknath Case", "Kesavananda Bharati Case", "Minerva Mills Case", "Maneka Gandhi Case"],
                a: 1
            },
            {
                q: "Under which article can the President project an Ordinance?",
                options: ["Article 123", "Article 213", "Article 356", "Article 72"],
                a: 0
            }
        ]
    };

    const handleStart = (diff) => {
        setDifficulty(diff);
        setGameState('playing');
        setCurrentQuestion(0);
        setScore(0);
    };

    const handleAnswer = (idx) => {
        if (isAnswered) return;
        setSelectedAnswer(idx);
        setIsAnswered(true);
        if (idx === questions[difficulty][currentQuestion].a) {
            setScore(s => s + 1);
        }
    };

    const nextQuestion = () => {
        const next = currentQuestion + 1;
        if (next < questions[difficulty].length) {
            setCurrentQuestion(next);
            setSelectedAnswer(null);
            setIsAnswered(false);
        } else {
            setGameState('results');
        }
    };

    if (gameState === 'selection') {
        return (
            <div className="max-w-4xl mx-auto space-y-12">
                <div className="text-center">
                    <h1 className="text-4xl font-black text-gray-900 mb-4">Daily Challenge</h1>
                    <p className="text-gray-500 font-bold text-lg">Test your legal knowledge and earn XP</p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <motion.button
                        whileHover={{ y: -10 }}
                        onClick={() => handleStart('easy')}
                        className="bg-white p-10 rounded-[44px] border border-gray-100 shadow-sm text-left group"
                    >
                        <div className="w-16 h-16 bg-emerald-500 rounded-3xl flex items-center justify-center text-white mb-8 shadow-xl shadow-emerald-500/20">
                            <Target size={32} />
                        </div>
                        <h3 className="text-2xl font-black text-gray-900 mb-2">Easy Quiz</h3>
                        <p className="text-gray-400 font-semibold text-sm mb-6">Foundational legal concepts. Perfect for beginners.</p>
                        <div className="flex items-center justify-between">
                            <span className="text-emerald-500 font-black text-sm">+100 XP Reward</span>
                            <div className="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center text-gray-300 group-hover:bg-emerald-500 group-hover:text-white transition-all">
                                <ChevronRight size={20} />
                            </div>
                        </div>
                    </motion.button>

                    <motion.button
                        whileHover={{ y: -10 }}
                        onClick={() => handleStart('hard')}
                        className="bg-white p-10 rounded-[44px] border border-gray-100 shadow-sm text-left group"
                    >
                        <div className="w-16 h-16 bg-orange-500 rounded-3xl flex items-center justify-center text-white mb-8 shadow-xl shadow-orange-500/20">
                            <Trophy size={32} />
                        </div>
                        <h3 className="text-2xl font-black text-gray-900 mb-2">Hard Quiz</h3>
                        <p className="text-gray-400 font-semibold text-sm mb-6">Expert level constitutional law and case history.</p>
                        <div className="flex items-center justify-between">
                            <span className="text-orange-500 font-black text-sm">+500 XP Reward</span>
                            <div className="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center text-gray-300 group-hover:bg-orange-500 group-hover:text-white transition-all">
                                <ChevronRight size={20} />
                            </div>
                        </div>
                    </motion.button>
                </div>
            </div>
        );
    }

    if (gameState === 'results') {
        const total = questions[difficulty].length;
        const passed = score / total >= 0.7;

        return (
            <div className="max-w-2xl mx-auto py-10">
                <motion.div
                    initial={{ scale: 0.9, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    className="bg-white p-12 rounded-[50px] border border-gray-100 shadow-2xl text-center space-y-8"
                >
                    <div className="relative inline-block">
                        <div className={`w-32 h-32 rounded-full flex items-center justify-center ${passed ? 'bg-emerald-100 text-emerald-600' : 'bg-red-100 text-red-600'} mx-auto`}>
                            {passed ? <Trophy size={64} /> : <XCircle size={64} />}
                        </div>
                        {passed && (
                            <motion.div
                                animate={{ rotate: 360 }}
                                transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                                className="absolute inset-[-10px] border-4 border-dashed border-emerald-500/30 rounded-full"
                            ></motion.div>
                        )}
                    </div>

                    <div>
                        <h2 className="text-4xl font-black text-gray-900 mb-2">{passed ? 'Excellent Work!' : 'Keep Learning'}</h2>
                        <p className="text-gray-500 font-bold">You scored {score} out of {total} questions correctly.</p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="bg-gray-50 p-6 rounded-3xl border border-gray-100">
                            <p className="text-gray-400 text-xs font-black uppercase tracking-widest mb-1">XP Earned</p>
                            <p className="text-3xl font-black text-primary">+{passed ? (difficulty === 'easy' ? 100 : 500) : 0}</p>
                        </div>
                        <div className="bg-gray-50 p-6 rounded-3xl border border-gray-100">
                            <p className="text-gray-400 text-xs font-black uppercase tracking-widest mb-1">New Streak</p>
                            <div className="flex items-center justify-center gap-2 text-3xl font-black text-orange-500">
                                <Flame size={28} /> 12
                            </div>
                        </div>
                    </div>

                    <div className="flex gap-4">
                        <button
                            onClick={() => setGameState('selection')}
                            className="flex-1 bg-gray-100 text-gray-600 py-5 rounded-3xl font-black flex items-center justify-center gap-2"
                        >
                            <RotateCcw size={20} /> Retake
                        </button>
                        <button
                            onClick={() => navigate('/dashboard')}
                            className="flex-1 premium-gradient text-white py-5 rounded-3xl font-black shadow-xl shadow-primary/20"
                        >
                            Return Home
                        </button>
                    </div>
                </motion.div>
            </div>
        );
    }

    const currentQ = questions[difficulty][currentQuestion];

    return (
        <div className="max-w-3xl mx-auto space-y-10 py-6">
            <div className="flex items-center justify-between">
                <button
                    onClick={() => setGameState('selection')}
                    className="p-3 bg-white rounded-2xl border border-gray-100 text-gray-400 hover:text-primary transition-colors"
                >
                    <ChevronLeft size={24} />
                </button>
                <div className="flex-1 px-10">
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                        <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${((currentQuestion + 1) / questions[difficulty].length) * 100}%` }}
                            className="h-full premium-gradient"
                        />
                    </div>
                </div>
                <div className="text-right">
                    <span className="text-xs font-black text-gray-400 uppercase tracking-widest">Question</span>
                    <p className="text-xl font-black text-gray-900 leading-none">{currentQuestion + 1} / {questions[difficulty].length}</p>
                </div>
            </div>

            <div className="space-y-8">
                <div className="bg-white p-10 rounded-[44px] border border-gray-100 shadow-sm relative overflow-hidden">
                    <div className="absolute top-0 right-0 p-8 opacity-5 text-gray-900 pointer-events-none">
                        <BookOpen size={120} />
                    </div>
                    <h2 className="text-2xl font-black text-gray-900 leading-tight relative z-10">
                        {currentQ.q}
                    </h2>
                </div>

                <div className="grid grid-cols-1 gap-4">
                    {currentQ.options.map((option, idx) => (
                        <motion.button
                            key={idx}
                            whileHover={{ scale: 1.01 }}
                            whileTap={{ scale: 0.99 }}
                            onClick={() => handleAnswer(idx)}
                            className={`p-6 rounded-3xl border text-left font-bold transition-all relative overflow-hidden ${isAnswered
                                    ? idx === currentQ.a
                                        ? 'bg-emerald-50 border-emerald-500 text-emerald-700'
                                        : idx === selectedAnswer
                                            ? 'bg-red-50 border-red-500 text-red-700'
                                            : 'bg-white border-gray-100 text-gray-400'
                                    : 'bg-white border-gray-100 text-gray-600 hover:border-primary/30 hover:shadow-md'
                                }`}
                        >
                            <div className="flex items-center gap-4">
                                <span className={`w-8 h-8 rounded-xl flex items-center justify-center text-xs font-black ${isAnswered && idx === currentQ.a ? 'bg-emerald-500 text-white' : 'bg-gray-100 text-gray-400'
                                    }`}>
                                    {String.fromCharCode(65 + idx)}
                                </span>
                                {option}
                            </div>

                            {isAnswered && idx === currentQ.a && (
                                <CheckCircle2 className="absolute right-6 top-1/2 -translate-y-1/2 text-emerald-500" size={24} />
                            )}
                        </motion.button>
                    ))}
                </div>
            </div>

            <AnimatePresence>
                {isAnswered && (
                    <motion.div
                        initial={{ y: 50, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        className="fixed bottom-10 left-0 right-0 md:left-64 px-10 flex justify-center pointer-events-none"
                    >
                        <button
                            onClick={nextQuestion}
                            className="pointer-events-auto px-12 py-5 premium-gradient text-white rounded-[30px] font-black shadow-2xl shadow-primary/40 flex items-center gap-3 hover:scale-105 transition-transform"
                        >
                            {currentQuestion + 1 === questions[difficulty].length ? 'See Results' : 'Next Question'}
                            <ChevronRight size={24} />
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default QuizPage;
