const { watch, src, dest, parallel } = require('gulp')
const sass = require('gulp-sass')(require('sass'))
const postcss = require('gulp-postcss')
const sourcemaps = require('gulp-sourcemaps')
const log = require('fancy-log')
const { rollup } = require('rollup')
const { nodeResolve } = require('@rollup/plugin-node-resolve')
const commonjs = require('@rollup/plugin-commonjs')
const { babel } = require('@rollup/plugin-babel')
const execShPromise = require('exec-sh').promise

const javascriptEntryPoint = 'app/javascript/application.js'
const sassEntrypoint = 'app/assets/stylesheets/application.scss'
const outputFolder = 'app/assets/builds'

async function javascript () {
  const bundle = await rollup({
    input: javascriptEntryPoint,
    plugins: [nodeResolve(), commonjs(), babel({ babelHelpers: 'bundled' })]
  })

  await bundle.write({
    dir: outputFolder,
    format: 'es',
    inlineDynamicImports: true,
    sourcemap: true
  })
}

function css () {
  return src(sassEntrypoint)
    .pipe(sourcemaps.init())
    .pipe(
      sass({
        includePaths: './node_modules/govuk-frontend/',
        quietDeps: true
      }).on('error', function (err) {
        log.error(err.message)
      })
    )
    .pipe(postcss())
    .pipe(sourcemaps.write('.'))
    .pipe(dest(outputFolder))
}

async function lint () {
  try {
    await execShPromise('yarn lint', [])
  } catch {}
}

const buildAndLint = parallel(css, javascript, lint)
const buildAndLintCss = parallel(css, lint)
const buildAndLintJs = parallel(javascript, lint)

const dev = function () {
  buildAndLint()
  watch('app/assets/stylesheets/**/*.scss', buildAndLintCss)
  watch('app/javascript/*.js', buildAndLintJs)
}

module.exports = {
  css,
  javascript,
  dev
}
