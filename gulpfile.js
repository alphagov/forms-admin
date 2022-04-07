const { watch, src, dest, parallel } = require('gulp')
const sass = require('gulp-sass')(require('sass'))
const postcss = require('gulp-postcss')
const sourcemaps = require('gulp-sourcemaps')
const log = require('fancy-log')
const { rollup } = require('rollup')
const { nodeResolve } = require('@rollup/plugin-node-resolve')
const commonjs = require('@rollup/plugin-commonjs')
const command = require('rollup-plugin-command')
const { babel } = require('@rollup/plugin-babel')

const sassSourceFile = 'app/assets/stylesheets/application.scss'
const outputFolder = 'app/assets/builds'

async function javascript () {
  const bundle = await rollup({
    input: 'app/javascript/application.js',
    plugins: [
      nodeResolve(),
      commonjs(),
      command('npm run lint'),
      babel({ babelHelpers: 'bundled' })
    ]
  })

  await bundle.write({
    file: 'app/assets/builds/application.js',
    format: 'es',
    inlineDynamicImports: true,
    sourcemap: true
  })
}

function css () {
  return src(sassSourceFile)
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

const build = parallel(css, javascript)

const watchTask = async function () {
  build()
  watch(['app/assets/stylesheets/**/*.scss', 'app/javascript/*.js'], build)
}

module.exports = {
  css,
  javascript,
  watch: watchTask
}
