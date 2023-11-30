import { initAll } from 'govuk-frontend'
import dfeAutocomplete from 'dfe-autocomplete'
import copyToClipboard from '../javascript/copy-to-clipboard'
import markdownEditorToolbar from '../javascript/markdown-editor-toolbar'
import { pasteListener } from '../javascript/paste-html-to-markdown'
import ajaxMarkdownPreview from '../javascript/ajax-markdown-preview'

document
  .querySelectorAll('[data-module="copy-to-clipboard"]')
  .forEach(element => {
    copyToClipboard(
      element,
      element.querySelector('[data-copy-target]'),
      element.dataset.copyButtonText
    )
  })

document
  .querySelectorAll('[data-module="markdown-editor-toolbar"]')
  .forEach(element => {
    markdownEditorToolbar(
      element,
      JSON.parse(element.getAttribute('data-i18n')),
      element.getAttribute('data-allow-headings') === 'true'
    )
    element.addEventListener('paste', pasteListener)
  })

document
  .querySelectorAll('[data-module="ajax-markdown-preview"]')
  .forEach(element => {
    ajaxMarkdownPreview(
      element.querySelector('[data-ajax-markdown-target]'),
      element.querySelector('[data-ajax-markdown-source]'),
      element.getAttribute('data-ajax-markdown-endpoint'),
      JSON.parse(element.getAttribute('data-i18n'))
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
