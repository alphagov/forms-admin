const autoprefixer = require('autoprefixer')
const cssnano = require('cssnano')

module.exports = {
  plugins: [autoprefixer({ grid: 'no-autoplace' }), cssnano()]
}
