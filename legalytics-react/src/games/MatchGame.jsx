import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Scale,
    ChevronLeft,
    ChevronRight,
    CheckCircle2,
    XCircle,
    RotateCcw,
    Trophy
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const MatchGame = () => {
    const navigate = useNavigate();

    // Static sample data (to be replaced by Firestore logic)
    const [gameData] = useState([
        {
            laws: ['Article 19', 'Article 21', 'Article 14'],
            descriptions: {
                'Article 19': 'Protection of certain rights regarding freedom of speech, etc.',
                'Article 21': 'Protection of life and personal liberty.',
                'Article 14': 'Equality before law and equal protection of laws.'
            }
        }
    ]);

    const [currentIndex, setCurrentIndex] = useState(0);
    const [matched, setMatched] = useState({});
    const [availableLaws, setAvailableLaws] = useState([]);
    const [showResult, setShowResult] = useState(false);
    const [draggedLaw, setDraggedLaw] = useState(null);

    const currentSet = gameData[currentIndex];

    useEffect(() => {
        if (currentSet) {
            setAvailableLaws([...currentSet.laws]);
            setMatched({});
            setShowResult(false);
        }
    }, [currentIndex, currentSet]);

    const handleDragStart = (law) => {
        setDraggedLaw(law);
    };

    const handleDrop = (descriptionKey) => {
        if (!draggedLaw) return;

        setMatched(prev => ({ ...prev, [descriptionKey]: draggedLaw }));
        setAvailableLaws(prev => prev.filter(l => l !== draggedLaw));
        setDraggedLaw(null);
    };

    const checkAnswers = () => {
        setShowResult(true);
    };

    return (
        <div className="max-w-4xl mx-auto space-y-8 pb-20">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <button
                        onClick={() => navigate('/dashboard')}
                        className="p-3 bg-white rounded-2xl border border-gray-100 text-gray-400 hover:text-primary transition-colors"
                    >
                        <ChevronLeft size={24} />
                    </button>
                    <div>
                        <h1 className="text-2xl font-black text-gray-900">Match the Law</h1>
                        <p className="text-gray-400 text-xs font-black uppercase tracking-widest">Level 1: Constitutional Rights</p>
                    </div>
                </div>
                <div className="bg-primary/10 px-6 py-2 rounded-2xl border border-primary/20">
                    <span className="text-primary font-black">{currentIndex + 1} / {gameData.length}</span>
                </div>
            </div>

            {/* Instruction */}
            <div className="bg-white/60 border border-primary/10 p-6 rounded-[24px] flex items-center gap-4">
                <div className="w-10 h-10 bg-primary/20 rounded-full flex items-center justify-center text-primary text-xl">💡</div>
                <p className="text-primary font-bold text-sm">Drag the law badges from the bottom and drop them onto the correct legal description above.</p>
            </div>

            {/* Match List */}
            <div className="space-y-4">
                {currentSet.laws.map((lawKey) => (
                    <div key={lawKey} className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm flex items-center gap-6">
                        <p className="flex-1 font-bold text-gray-700 leading-relaxed">
                            {currentSet.descriptions[lawKey]}
                        </p>

                        <div
                            onDragOver={(e) => e.preventDefault()}
                            onDrop={() => handleDrop(lawKey)}
                            className={`
                w-40 h-16 rounded-2xl border-2 border-dashed flex items-center justify-center transition-all
                ${matched[lawKey]
                                    ? 'bg-gray-50 border-primary/20 scale-105 shadow-sm'
                                    : 'bg-gray-50/50 border-gray-200 text-gray-300'}
                ${showResult && matched[lawKey] === lawKey ? 'bg-emerald-50 border-emerald-500 text-emerald-700' : ''}
                ${showResult && matched[lawKey] && matched[lawKey] !== lawKey ? 'bg-red-50 border-red-500 text-red-700' : ''}
              `}
                        >
                            {matched[lawKey] ? (
                                <span className="font-black text-sm">{matched[lawKey]}</span>
                            ) : (
                                <span className="text-xs font-black uppercase tracking-widest opacity-40">Drop Here</span>
                            )}
                        </div>
                    </div>
                ))}
            </div>

            {/* Draggable Laws */}
            <div className="fixed bottom-0 left-0 right-0 md:left-64 p-6 bg-white border-t border-gray-100 flex flex-col items-center gap-6 z-20">
                <div className="flex flex-wrap justify-center gap-4">
                    <AnimatePresence>
                        {availableLaws.map((law) => (
                            <motion.div
                                key={law}
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                exit={{ scale: 0 }}
                                draggable
                                onDragStart={() => handleDragStart(law)}
                                className="px-6 py-3 premium-gradient text-white rounded-xl font-black text-sm cursor-grab active:cursor-grabbing shadow-lg shadow-primary/20 hover:scale-110 transition-transform"
                            >
                                {law}
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>

                <div className="w-full max-w-md flex items-center gap-4">
                    <button
                        onClick={() => {
                            setAvailableLaws([...currentSet.laws]);
                            setMatched({});
                            setShowResult(false);
                        }}
                        className="p-4 bg-gray-50 text-gray-400 rounded-2xl border border-gray-100 hover:text-primary transition-colors"
                    >
                        <RotateCcw size={24} />
                    </button>

                    <button
                        disabled={availableLaws.length > 0 || showResult}
                        onClick={checkAnswers}
                        className="flex-1 premium-gradient text-white py-4 rounded-2xl font-black shadow-xl shadow-primary/30 disabled:opacity-30 disabled:shadow-none transition-all"
                    >
                        {showResult ? 'Check Results' : 'Submit Answers'}
                    </button>

                    {showResult && (
                        <button
                            onClick={() => navigate('/dashboard')}
                            className="p-4 bg-emerald-50 text-emerald-600 rounded-2xl border border-emerald-100 font-bold"
                        >
                            Finish
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default MatchGame;
