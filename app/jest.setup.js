// Mock NativeWind
jest.mock('nativewind', () => ({
  styled: () => (Component) => Component,
}));

// Mock expo-linear-gradient
jest.mock('expo-linear-gradient', () => ({
  LinearGradient: 'LinearGradient',
}));

// Mock expo-haptics
jest.mock('expo-haptics', () => ({
  impactAsync: jest.fn(),
  ImpactFeedbackStyle: {
    Light: 'light',
    Medium: 'medium',
    Heavy: 'heavy',
  },
}));

// Mock react-native-reanimated
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});

// Mock @react-native-async-storage/async-storage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

// Mock expo-router
jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => ({}),
  Link: 'Link',
  Stack: 'Stack',
  Tabs: 'Tabs',
}));

// Mock lucide-react-native
jest.mock('lucide-react-native', () => ({
  ChevronRight: 'ChevronRight',
  ChevronLeft: 'ChevronLeft',
  ChevronDown: 'ChevronDown',
  X: 'X',
  Sun: 'Sun',
  Moon: 'Moon',
  Sparkles: 'Sparkles',
  Activity: 'Activity',
  Heart: 'Heart',
  Wind: 'Wind',
  Droplets: 'Droplets',
  Thermometer: 'Thermometer',
  Cloud: 'Cloud',
  CloudRain: 'CloudRain',
  CheckCircle2: 'CheckCircle2',
  TrendingUp: 'TrendingUp',
  TrendingDown: 'TrendingDown',
  Minus: 'Minus',
  Play: 'Play',
  Pause: 'Pause',
  ArrowRight: 'ArrowRight',
  Target: 'Target',
  Footprints: 'Footprints',
}));

// Silence the warning: Animated: `useNativeDriver` is not supported
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

