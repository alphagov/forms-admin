/// <reference types="vitest" />

import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import * as path from 'node:path'
import lintPlugin from './app/frontend/plugins/vite/vite-plugin-lint'

export default defineConfig({
  plugins: [RubyPlugin(), { ...lintPlugin(), apply: 'serve' }],
  build: { emptyOutDir: true },
  css: {
    preprocessorOptions: {
      scss: {
        includePaths: ['./node_modules/govuk-frontend/'],
        quietDeps: true
      },
      devSourcemaps: true
    }
  },
  resolve: {
    alias: {
      '@govuk': path.resolve(
        __dirname,
        'node_modules/govuk-frontend/dist/govuk'
      ),
      '@images': path.resolve(__dirname, 'app/frontend/images')
    }
  },
  test: {
    globals: true
  }
})
