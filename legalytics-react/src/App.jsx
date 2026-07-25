import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import LoginPage from './pages/LoginPage';
import HomePage from './pages/HomePage';
import Dashboard from './pages/Dashboard';
import Chatbot from './pages/Chatbot';
import Learning from './pages/Learning';
import Quiz from './pages/Quiz';
import MockParliament from './pages/MockParliament';
import Leaderboard from './pages/Leaderboard';
import Games from './pages/Games';
import MatchGame from './games/MatchGame';
import TrafficRunnerGame from './games/TrafficRunnerGame';
import CivicAssemblyGame from './games/CivicAssemblyGame';
import News from './pages/News';
import Profile from './pages/Profile';
import './index.css';

const ProtectedRoute = ({ children }) => {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  return children;
};

const MainLayout = ({ children }) => {
  return (
    <div className="flex min-h-screen bg-[#F0F0F8]">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Navbar />
        <main className="flex-1 p-6">
          {children}
        </main>
      </div>
    </div>
  );
};

const App = () => {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<ProtectedRoute><MainLayout><HomePage /></MainLayout></ProtectedRoute>} />
          <Route path="/dashboard" element={<ProtectedRoute><MainLayout><Dashboard /></MainLayout></ProtectedRoute>} />
          <Route path="/chatbot" element={<ProtectedRoute><MainLayout><Chatbot /></MainLayout></ProtectedRoute>} />
          <Route path="/learning" element={<ProtectedRoute><MainLayout><Learning /></MainLayout></ProtectedRoute>} />
          <Route path="/quiz" element={<ProtectedRoute><MainLayout><Quiz /></MainLayout></ProtectedRoute>} />
          <Route path="/parliament" element={<ProtectedRoute><MainLayout><MockParliament /></MainLayout></ProtectedRoute>} />
          <Route path="/leaderboard" element={<ProtectedRoute><MainLayout><Leaderboard /></MainLayout></ProtectedRoute>} />
          <Route path="/games" element={<ProtectedRoute><MainLayout><Games /></MainLayout></ProtectedRoute>} />
          <Route path="/games/match" element={<ProtectedRoute><MainLayout><MatchGame /></MainLayout></ProtectedRoute>} />
          <Route path="/games/runner" element={<ProtectedRoute><MainLayout><TrafficRunnerGame /></MainLayout></ProtectedRoute>} />
          <Route path="/games/assembly" element={<ProtectedRoute><MainLayout><CivicAssemblyGame /></MainLayout></ProtectedRoute>} />
          <Route path="/news" element={<ProtectedRoute><MainLayout><News /></MainLayout></ProtectedRoute>} />
          <Route path="/profile" element={<ProtectedRoute><MainLayout><Profile /></MainLayout></ProtectedRoute>} />
        </Routes>
      </Router>
    </AuthProvider>
  );
};

export default App;
