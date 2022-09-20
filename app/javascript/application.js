// Entry point for the build script in your package.json
import { initAll } from 'govuk-frontend'
import copyToClipboard from './modules/copy-to-clipboard'

document
  .querySelectorAll('[data-module="copy-to-clipboard"]')
  .forEach(element => {
    copyToClipboard(
      element,
      element.querySelector('[data-copy-target]'),
      element.dataset.copyButtonText
    )
  })

initAll()
