import { initAll } from 'govuk-frontend'
import copyToClipboard from '../javascript/copy-to-clipboard'
import dfeAutocomplete from 'dfe-autocomplete'

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

dfeAutocomplete({})
