import React, { useState, useEffect } from 'react';
import { fetchNews, translateText } from '../services/news';
import { Languages, ExternalLink, Calendar, Search, Newspaper } from 'lucide-react';
import { motion } from 'framer-motion';

const News = () => {
    const [articles, setArticles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [lang, setLang] = useState('English');
    const [translating, setTranslating] = useState(false);

    const languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Marathi', 'Malayalam', 'Kannada', 'Bengali'];

    useEffect(() => {
        loadNews();
    }, []);

    const loadNews = async () => {
        setLoading(true);
        const data = await fetchNews();
        setArticles(data.slice(0, 10)); // Limit to 10 for performance
        setLoading(false);
    };

    const handleLangChange = async (newLang) => {
        setLang(newLang);
        if (newLang === 'English') {
            loadNews();
            return;
        }

        setTranslating(true);
        const translatedArticles = await Promise.all(
            articles.map(async (art) => ({
                ...art,
                title: await translateText(art.title, newLang),
                description: await translateText(art.description, newLang)
            }))
        );
        setArticles(translatedArticles);
        setTranslating(false);
    };

    return (
        <div className="max-w-5xl mx-auto space-y-8">
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div>
                    <h1 className="text-4xl font-black text-gray-900 mb-2">Legal News</h1>
                    <p className="text-gray-500 font-bold">Stay updated with Indian legal developments</p>
                </div>

                <div className="flex items-center gap-3 bg-white px-4 py-2 rounded-2xl border border-gray-100 shadow-sm">
                    <Languages size={20} className="text-primary" />
                    <select
                        value={lang}
                        onChange={(e) => handleLangChange(e.target.value)}
                        className="outline-none bg-transparent text-sm font-black text-gray-700 cursor-pointer"
                    >
                        {languages.map(l => <option key={l} value={l}>{l}</option>)}
                    </select>
                </div>
            </div>

            {loading || translating ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {[1, 2, 3, 4].map(i => (
                        <div key={i} className="bg-white rounded-[32px] p-6 h-96 animate-pulse border border-gray-100">
                            <div className="w-full h-48 bg-gray-100 rounded-2xl mb-6"></div>
                            <div className="h-6 bg-gray-100 rounded-full w-3/4 mb-4"></div>
                            <div className="h-4 bg-gray-100 rounded-full w-full mb-2"></div>
                            <div className="h-4 bg-gray-100 rounded-full w-2/3"></div>
                        </div>
                    ))}
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {articles.map((art, idx) => (
                        <motion.div
                            key={idx}
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            whileHover={{ y: -5 }}
                            className="group bg-white rounded-[32px] overflow-hidden border border-gray-100 shadow-sm flex flex-col"
                        >
                            <div className="h-48 overflow-hidden relative">
                                <img
                                    src={art.urlToImage || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600'}
                                    alt={art.title}
                                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                                />
                                <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-md px-3 py-1 rounded-full border border-white/20">
                                    <span className="text-[10px] font-black uppercase tracking-widest text-primary">{art.source.name}</span>
                                </div>
                            </div>

                            <div className="p-8 flex flex-col flex-1">
                                <div className="flex items-center gap-2 text-gray-400 text-xs font-black uppercase tracking-widest mb-4">
                                    <Calendar size={14} />
                                    <span>{new Date(art.publishedAt).toLocaleDateString()}</span>
                                </div>

                                <h3 className="text-xl font-black text-gray-900 mb-4 line-clamp-2 leading-tight">
                                    {art.title}
                                </h3>

                                <p className="text-gray-500 font-semibold text-sm leading-relaxed mb-8 line-clamp-3">
                                    {art.description}
                                </p>

                                <div className="mt-auto pt-6 border-t border-gray-50 flex items-center justify-between">
                                    <a
                                        href={art.url}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="flex items-center gap-2 text-primary font-black text-sm group/btn"
                                    >
                                        Read Full Article <ExternalLink size={16} className="group-hover/btn:translate-x-1 transition-transform" />
                                    </a>
                                    <div className="flex items-center gap-1 text-xs font-bold text-gray-400">
                                        <span className="w-1.5 h-1.5 bg-gray-200 rounded-full"></span>
                                        {art.author || 'News Desk'}
                                    </div>
                                </div>
                            </div>
                        </motion.div>
                    ))}
                </div>
            )}

            {articles.length === 0 && !loading && (
                <div className="text-center py-20 flex flex-col items-center">
                    <div className="w-20 h-20 bg-gray-100 rounded-3xl flex items-center justify-center text-gray-400 mb-6">
                        <Newspaper size={40} />
                    </div>
                    <h3 className="text-xl font-black text-gray-900">No News Found</h3>
                    <p className="text-gray-500 font-semibold">Try searching for different legal topics.</p>
                </div>
            )}
        </div>
    );
};

export default News;
