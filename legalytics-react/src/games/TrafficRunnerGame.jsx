import React, { useEffect, useRef, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ShieldAlert, RotateCcw, Play, ChevronLeft, Award } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const TrafficRunnerGame = () => {
    const canvasRef = useRef(null);
    const navigate = useNavigate();
    const [gameState, setGameState] = useState('start'); // 'start', 'playing', 'paused', 'gameover'
    const [score, setScore] = useState(0);
    const [highScore, setHighScore] = useState(0);
    const [collisionLaw, setCollisionLaw] = useState(null);

    // Game Constants
    const LANES = [100, 200, 300]; // X positions
    const LANE_WIDTH = 100;
    const PLAYER_Y = 500;
    const PLAYER_SIZE = 60;
    const OBSTACLE_SIZE = 50;
    const INITIAL_SPEED = 5;

    // Mutable Game State
    const gameRef = useRef({
        playerLane: 1, // 0, 1, 2
        obstacles: [],
        speed: INITIAL_SPEED,
        frameCount: 0,
        requestId: null
    });

    const trafficLaws = [
        { title: "IPC Section 279", desc: "Rash driving or riding on a public way. Punishable with imprisonment up to 6 months or fine." },
        { title: "IPC Section 337", desc: "Causing hurt by act endangering life or personal safety of others." },
        { title: "IPC Section 304A", desc: "Causing death by negligence. Non-bailable offense in many contexts." }
    ];

    const startGame = () => {
        setGameState('playing');
        setScore(0);
        gameRef.current = {
            playerLane: 1,
            obstacles: [],
            speed: INITIAL_SPEED,
            frameCount: 0,
            requestId: null
        };
        requestAnimationFrame(gameLoop);
    };

    const gameLoop = () => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        const g = gameRef.current;

        // Clear Canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // Draw Road
        ctx.fillStyle = '#334155';
        ctx.fillRect(50, 0, 300, 600);

        // Road Lines
        ctx.setLineDash([20, 20]);
        ctx.strokeStyle = '#94A3B8';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(150, 0); ctx.lineTo(150, 600);
        ctx.moveTo(250, 0); ctx.lineTo(250, 600);
        ctx.stroke();

        // Spawn Obstacles
        if (g.frameCount % 60 === 0) {
            const lane = Math.floor(Math.random() * 3);
            g.obstacles.push({
                x: LANES[lane],
                y: -100,
                type: Math.random() > 0.8 ? 'pedestrian' : 'car'
            });
        }

        // Update & Draw Obstacles
        ctx.setLineDash([]); // Reset dash for cars
        g.obstacles.forEach((obs, index) => {
            obs.y += g.speed;

            // Draw Obstacle
            ctx.fillStyle = obs.type === 'car' ? '#EF4444' : '#F59E0B';
            ctx.beginPath();
            ctx.roundRect(obs.x - 25, obs.y - 25, 50, 80, 10);
            ctx.fill();

            // Collision Detection
            const dx = obs.x - LANES[g.playerLane];
            const dy = obs.y - PLAYER_Y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < 50) {
                setGameState('gameover');
                setCollisionLaw(trafficLaws[Math.floor(Math.random() * trafficLaws.length)]);
                cancelAnimationFrame(g.requestId);
                return;
            }

            // Cleanup & Scoring
            if (obs.y > 700) {
                g.obstacles.splice(index, 1);
                setScore(s => s + 10);
            }
        });

        // Draw Player
        ctx.fillStyle = '#6C3AED';
        ctx.beginPath();
        ctx.roundRect(LANES[g.playerLane] - 30, PLAYER_Y - 30, 60, 90, 15);
        ctx.fill();
        // Player Details (Windshield)
        ctx.fillStyle = '#A5B4FC';
        ctx.fillRect(LANES[g.playerLane] - 20, PLAYER_Y - 20, 40, 15);

        // Increase speed
        g.speed += 0.001;
        g.frameCount++;

        if (gameState === 'playing' || gameState === 'start') {
            g.requestId = requestAnimationFrame(gameLoop);
        }
    };

    useEffect(() => {
        const handleKeyDown = (e) => {
            if (gameState !== 'playing') return;
            if (e.key === 'ArrowLeft' && gameRef.current.playerLane > 0) {
                gameRef.current.playerLane--;
            } else if (e.key === 'ArrowRight' && gameRef.current.playerLane < 2) {
                gameRef.current.playerLane++;
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => {
            window.removeEventListener('keydown', handleKeyDown);
            cancelAnimationFrame(gameRef.current.requestId);
        };
    }, [gameState]);

    return (
        <div className="max-w-4xl mx-auto h-[calc(100vh-140px)] flex flex-col items-center justify-center p-6 bg-slate-100 rounded-[40px] relative overflow-hidden">
            <div className="absolute top-8 left-8 flex items-center gap-4">
                <button
                    onClick={() => navigate('/dashboard')}
                    className="p-3 bg-white rounded-2xl border border-gray-100 text-gray-400 hover:text-primary transition-colors shadow-sm"
                >
                    <ChevronLeft size={24} />
                </button>
                <div>
                    <h1 className="text-xl font-black text-gray-900 leading-none">Traffic Runner</h1>
                    <p className="text-gray-400 text-[10px] font-black uppercase tracking-widest mt-1">Legal Survival Simulation</p>
                </div>
            </div>

            <div className="absolute top-8 right-8 text-right">
                <p className="text-gray-400 text-[10px] font-black uppercase tracking-widest">Score</p>
                <p className="text-3xl font-black text-primary">{score}</p>
            </div>

            <div className="relative group p-4 bg-slate-800 rounded-[40px] shadow-2xl overflow-hidden">
                <canvas
                    ref={canvasRef}
                    width={400}
                    height={600}
                    className="rounded-[32px] bg-slate-900"
                />

                <AnimatePresence>
                    {gameState === 'start' && (
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="absolute inset-0 bg-slate-900/80 backdrop-blur-sm flex flex-col items-center justify-center text-center p-10"
                        >
                            <div className="w-20 h-20 bg-primary/20 rounded-3xl flex items-center justify-center text-white mb-6 border border-white/20">
                                <Play size={40} fill="currentColor" />
                            </div>
                            <h2 className="text-3xl font-black text-white mb-4">Learn Road Safety</h2>
                            <p className="text-slate-400 font-bold mb-8 max-w-xs">
                                Use Arrow Keys to switch lanes. Dodge other vehicles and pedestrians. A single mistake can lead to legal consequences!
                            </p>
                            <button
                                onClick={startGame}
                                className="px-12 py-4 premium-gradient text-white rounded-2xl font-black shadow-xl shadow-primary/30 hover:scale-105 transition-transform"
                            >
                                Start Mission
                            </button>
                        </motion.div>
                    )}

                    {gameState === 'gameover' && (
                        <motion.div
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            className="absolute inset-0 bg-red-600/90 backdrop-blur-md flex flex-col items-center justify-center text-center p-10 text-white"
                        >
                            <ShieldAlert size={80} className="mb-6 animate-bounce" />
                            <h2 className="text-4xl font-black mb-2">CHALLAN ISSUED!</h2>
                            <p className="text-red-100 font-bold text-sm mb-8 uppercase tracking-widest">Legal Education Alert</p>

                            <div className="bg-white/10 p-6 rounded-3xl border border-white/20 mb-10 w-full">
                                <h3 className="text-xl font-black mb-2">{collisionLaw?.title}</h3>
                                <p className="text-red-50 font-medium leading-relaxed">
                                    {collisionLaw?.desc}
                                </p>
                            </div>

                            <div className="flex gap-4 w-full">
                                <button
                                    onClick={startGame}
                                    className="flex-1 bg-white text-red-600 py-4 rounded-2xl font-black shadow-xl flex items-center justify-center gap-2 hover:bg-red-50 transition-colors"
                                >
                                    <RotateCcw size={20} /> Try Again
                                </button>
                                <div className="flex-1 bg-red-700/50 py-4 rounded-2xl font-black border border-white/20 flex flex-col justify-center">
                                    <span className="text-[10px] opacity-70">Final Score</span>
                                    <span className="text-xl">{score}</span>
                                </div>
                            </div>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>

            <div className="mt-8 flex gap-8">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-white rounded-xl shadow-sm flex items-center justify-center text-gray-400 border border-slate-200">
                        <Award size={20} />
                    </div>
                    <div>
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none">Best Score</p>
                        <p className="text-lg font-black text-slate-700 leading-none mt-1">{highScore}</p>
                    </div>
                </div>
                <div className="text-slate-400 font-bold text-xs flex items-center gap-2">
                    <div className="flex gap-1">
                        <kbd className="px-2 py-1 bg-white rounded border border-slate-200 text-slate-600">←</kbd>
                        <kbd className="px-2 py-1 bg-white rounded border border-slate-200 text-slate-600">→</kbd>
                    </div>
                    Use keys to swerve
                </div>
            </div>
        </div>
    );
};

export default TrafficRunnerGame;
