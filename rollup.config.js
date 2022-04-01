import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import scss from 'rollup-plugin-scss'
import postcss from 'postcss'
import autoprefixer from 'autoprefixer'
import command from 'rollup-plugin-command'
import { babel } from '@rollup/plugin-babel'

export default [
  {
    input: 'app/javascript/application.js',
    output: {
      file: 'app/assets/builds/application.js',
      format: 'es',
      inlineDynamicImports: true,
      sourcemap: true
    },
    plugins: [
      resolve(),
      commonjs(),
      command('npm run lint'),
      scss({
        processor: () => postcss([autoprefixer({ grid: 'no-autoplace' })]),
        output: true,
        sourceMap: true,
        quietDeps: true
      }),
      babel({ babelHelpers: 'bundled' })
    ]
  }
]
