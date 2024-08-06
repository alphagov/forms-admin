import { initAll } from 'govuk-frontend'
import dfeAutocomplete from 'dfe-autocomplete'
import copyToClipboard from '../javascript/copy-to-clipboard'
import markdownEditorToolbar from '../javascript/markdown-editor-toolbar'
import { pasteListener } from '../javascript/paste-html-to-markdown'
import {
  installAnalyticsScript,
  sendPageViewEvent,
  attachExternalLinkTracker
} from '../javascript/google-tag'
import { saveConsentStatus } from '../javascript/utils/cookie-consent'
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

if (document.body.dataset.googleAnalyticsEnabled === 'true') {
  saveConsentStatus(true)
  installAnalyticsScript(window)
  sendPageViewEvent()
  attachExternalLinkTracker()
}

initAll()

window.dfeAutocomplete = dfeAutocomplete
