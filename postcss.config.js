import autoprefixer from 'autoprefixer'
import cssnano from 'cssnano'

export default {
  plugins: [autoprefixer({ grid: 'no-autoplace' }), cssnano()]
}
