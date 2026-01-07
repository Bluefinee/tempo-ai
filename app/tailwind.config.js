/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,jsx,ts,tsx}',
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        indigo: {
          50: '#EEF2FF',
          100: '#E0E7FF',
          500: '#6366F1',
          900: '#312E81',
        },
        amber: {
          50: '#FFFBEB',
          100: '#FEF3C7',
          400: '#FBBF24',
          500: '#F59E0B',
        },
        rose: {
          50: '#FFF1F2',
          400: '#FB7185',
          500: '#F43F5E',
        },
        stone: {
          50: '#FAFAF9',
          100: '#F5F5F4',
          200: '#E7E5E4',
          400: '#A8A29E',
          500: '#78716C',
          600: '#57534E',
          700: '#44403C',
          800: '#292524',
          900: '#1C1917',
        },
        emerald: {
          50: '#ECFDF5',
          500: '#10B981',
          600: '#059669',
        },
      },
      fontFamily: {
        sans: ['PlusJakartaSans-Regular'],
        serif: ['serif'],
        mono: ['monospace'],
      },
    },
  },
  plugins: [],
};
