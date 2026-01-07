import expoConfig from 'eslint-config-expo/flat.js';

export default [
  ...expoConfig,
  {
    ignores: ['node_modules/', '.expo/', 'dist/', 'build/', 'jest.setup.js', 'jest.config.js'],
  },
];
