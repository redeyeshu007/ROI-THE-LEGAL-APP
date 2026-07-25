import React, { useState } from 'react';
import {
    BookOpen,
    PlayCircle,
    CheckCircle2,
    ChevronLeft,
    Clock,
    Shield,
    Gavel,
    Users,
    ShieldAlert
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const LearningPage = () => {
    const [selectedModule, setSelectedModule] = useState(null);
    const [activeLesson, setActiveLesson] = useState(null);

    const modules = [
        {
            id: 1,
            title: 'Fundamental Rights',
            icon: Shield,
            desc: 'Learn about your basic constitutional rights in India.',
            color: 'bg-blue-500',
            lessons: [
                { id: '1-1', title: 'Right to Equality (Art 14-18)', dur: '6 min', videoId: 'dQw4w9WgXcQ' },
                { id: '1-2', title: 'Right to Freedom (Art 19-22)', dur: '8 min', videoId: 'dQw4w9WgXcQ' },
                { id: '1-3', title: 'Right against Exploitation', dur: '5 min', videoId: 'dQw4w9WgXcQ' }
            ]
        },
        {
            id: 2,
            title: 'Indian Penal Code',
            icon: Gavel,
            desc: 'Understand criminal laws and procedures.',
            color: 'bg-purple-500',
            lessons: [
                { id: '2-1', title: 'IPC vs BNS Overview', dur: '10 min', videoId: 'dQw4w9WgXcQ' },
                { id: '2-2', title: 'Offences against Person', dur: '12 min', videoId: 'dQw4w9WgXcQ' },
                { id: '2-3', title: 'Public Tranquility Laws', dur: '7 min', videoId: 'dQw4w9WgXcQ' }
            ]
        },
        {
            id: 3,
            title: 'Cyber Laws',
            icon: ShieldAlert,
            desc: 'Protect yourself in the digital legal landscape.',
            color: 'bg-emerald-500',
            lessons: [
                { id: '3-1', title: 'IT Act 2000 Basics', dur: '7 min', videoId: 'dQw4w9WgXcQ' },
                { id: '3-2', title: 'Data Privacy Laws', dur: '9 min', videoId: 'dQw4w9WgXcQ' }
            ]
        },
        {
            id: 4,
            title: 'Family Law',
            icon: Users,
            desc: 'Marriage, succession, and guardianship laws.',
            color: 'bg-amber-500',
            lessons: [
                { id: '4-1', title: 'Hindu Marriage Act', dur: '10 min', videoId: 'dQw4w9WgXcQ' },
                { id: '4-2', title: 'Special Marriage Act', dur: '8 min', videoId: 'dQw4w9WgXcQ' }
            ]
        }
    ];

    if (selectedModule) {
        return (
            <div className="max-w-6xl mx-auto space-y-8">
                <button
                    onClick={() => { setSelectedModule(null); setActiveLesson(null); }}
                    className="flex items-center gap-2 text-gray-400 font-black hover:text-primary transition-colors"
                >
                    <ChevronLeft size={20} /> Back to Modules
                </button>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
                    <div className="lg:col-span-2 space-y-6">
                        <div className="aspect-video bg-black rounded-[40px] overflow-hidden shadow-2xl relative">
                            {activeLesson ? (
                                <iframe
                                    className="w-full h-full"
                                    src={`https://www.youtube.com/embed/${activeLesson.videoId}?autoplay=1`}
                                    title="Lesson Video"
                                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                    allowFullScreen
                                ></iframe>
                            ) : (
                                <div className="w-full h-full flex flex-col items-center justify-center text-white">
                                    <PlayCircle size={64} className="mb-4 opacity-50" />
                                    <p className="font-black text-xl">Select a lesson to start</p>
                                </div>
                            )}
                        </div>

                        <div className="bg-white p-8 rounded-[40px] border border-gray-100 shadow-sm">
                            <h1 className="text-3xl font-black text-gray-900 mb-4">
                                {activeLesson ? activeLesson.title : selectedModule.title}
                            </h1>
                            <p className="text-gray-500 font-semibold leading-relaxed">
                                In this lesson, we cover the core principles of {selectedModule.title.toLowerCase()} in the Indian legal system.
                                Pay close attention to the specific Articles and Sections mentioned, as they will appear in the final quiz.
                            </p>
                        </div>
                    </div>

                    <div className="space-y-6">
                        <div className="bg-white p-8 rounded-[40px] border border-gray-100 shadow-sm h-full">
                            <h3 className="text-xl font-black text-gray-900 mb-6 flex items-center gap-2">
                                <BookOpen className="text-primary" /> Lesson List
                            </h3>
                            <div className="space-y-3">
                                {selectedModule.lessons.map((lesson) => (
                                    <button
                                        key={lesson.id}
                                        onClick={() => setActiveLesson(lesson)}
                                        className={`w-full p-5 rounded-2xl border text-left flex items-center justify-between group transition-all ${activeLesson?.id === lesson.id
                                                ? 'bg-primary/5 border-primary text-primary shadow-sm'
                                                : 'bg-gray-50 border-transparent hover:border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        <div className="flex items-center gap-4">
                                            {activeLesson?.id === lesson.id ? <CheckCircle2 size={18} /> : <PlayCircle size={18} />}
                                            <div className="space-y-0.5">
                                                <p className="font-bold text-sm leading-tight">{lesson.title}</p>
                                                <div className="flex items-center gap-2 text-[10px] uppercase font-black tracking-widest opacity-60">
                                                    <Clock size={10} /> {lesson.dur}
                                                </div>
                                            </div>
                                        </div>
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="max-w-6xl mx-auto space-y-12">
            <div>
                <h1 className="text-4xl font-black text-gray-900 mb-2">Curriculum</h1>
                <p className="text-gray-500 font-bold text-lg">Master the laws of India through structured paths</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {modules.map((mod) => (
                    <motion.button
                        key={mod.id}
                        whileHover={{ scale: 1.02, y: -5 }}
                        onClick={() => setSelectedModule(mod)}
                        className="bg-white p-10 rounded-[44px] border border-gray-100 shadow-sm text-left group flex items-start gap-8"
                    >
                        <div className={`w-20 h-20 ${mod.color} rounded-3xl flex items-center justify-center text-white flex-shrink-0 shadow-lg shadow-black/5`}>
                            <mod.icon size={36} />
                        </div>
                        <div className="flex-1 space-y-3">
                            <h3 className="text-2xl font-black text-gray-900">{mod.title}</h3>
                            <p className="text-gray-400 font-semibold text-sm leading-relaxed">{mod.desc}</p>
                            <div className="pt-4 flex items-center justify-between">
                                <div className="flex items-center gap-2 text-xs font-black uppercase tracking-widest text-primary">
                                    {mod.lessons.length} Lessons <span className="text-gray-200">|</span> 2.5 Hrs
                                </div>
                                <div className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-300 group-hover:bg-primary/10 group-hover:text-primary transition-colors">
                                    <PlayCircle size={20} />
                                </div>
                            </div>
                        </div>
                    </motion.button>
                ))}
            </div>
        </div>
    );
};

export default LearningPage;
