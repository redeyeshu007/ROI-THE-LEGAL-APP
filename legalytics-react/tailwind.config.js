/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#6C3AED',
          light: '#8B5CF6',
          dark: '#4F46E5',
        },
        accent: {
          DEFAULT: '#F59E0B',
          light: '#FFFBEB',
        },
        surface: {
          DEFAULT: '#FFFFFF',
          alt: '#F3F4F6',
        }
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Plus Jakarta Sans', 'sans-serif'],
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  plugins: [],
}
