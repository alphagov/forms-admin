import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import { babel } from '@rollup/plugin-babel'

export default {
  input: 'app/javascript/application.js',
  output: {
    file: 'app/assets/builds/application.js',
    format: 'es',
    inlineDynamicImports: true,
    sourcemap: true
  },
  plugins: [resolve(), commonjs(), babel({ babelHelpers: 'bundled' })]
}
