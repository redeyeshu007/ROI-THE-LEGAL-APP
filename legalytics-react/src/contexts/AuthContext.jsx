import React, { createContext, useContext, useEffect, useState } from 'react';
import { auth, googleProvider } from '../services/firebase';
import {
    onAuthStateChanged,
    signInWithPopup,
    signInWithEmailAndPassword,
    signOut,
    createUserWithEmailAndPassword
} from 'firebase/auth';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (user) => {
            setUser(user);
            setLoading(false);
        });
        return unsubscribe;
    }, []);

    const loginWithGoogle = () => signInWithPopup(auth, googleProvider);
    const loginWithEmail = (email, pass) => signInWithEmailAndPassword(auth, email, pass);
    const register = (email, pass) => createUserWithEmailAndPassword(auth, email, pass);
    const logout = () => signOut(auth);

    const value = {
        user,
        loading,
        loginWithGoogle,
        loginWithEmail,
        register,
        logout
    };

    return (
        <AuthContext.Provider value={value}>
            {loading ? (
                <div className="min-h-screen flex flex-col items-center justify-center bg-[#0F0F1A]">
                    <div className="w-16 h-16 border-4 border-purple-500/20 border-t-purple-500 rounded-full animate-spin mb-4"></div>
                    <p className="text-purple-400 font-black uppercase tracking-[0.3em] text-xs">Syncing Legal Data...</p>
                </div>
            ) : children}
        </AuthContext.Provider>
    );
};
