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

// We set rawAttribute to true to pass the value of the text input to the
// controller when the autocomplete is being used, so we can detect when the
// user has cleared the field. We set source to false to overide the DfE
// component's handling of sort order and synonyms, as described in the code
// found in
// https://github.com/DFE-Digital/dfe-autocomplete/blob/36d80e6b5bba67c92cd9ec6982a4e536d1889aed/src/dfe-autocomplete.js#L54C1-L54C1
// this means the autocomplete will get options straight from the select
// element, removing the null option, which isn't needed for autocomplete.
dfeAutocomplete({
  rawAttribute: true,
  source: false
})
