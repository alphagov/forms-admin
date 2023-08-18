// Adapted from the [Paste HTML to govspeak](https://github.com/alphagov/paste-html-to-govspeak) package.

import htmlToMarkdown from './html-to-markdown'

const insertTextAtCursor = (field, contentToInsert) => {
  const selectionStart = field.selectionStart
  const selectionEnd = field.selectionEnd
  if (selectionStart || selectionStart == '0') {
    const contentBeforeSelection = field.value.substring(0, selectionStart)
    const contentAfterSelection = field.value.substring(
      selectionEnd,
      field.value.length
    )
    field.value = `${contentBeforeSelection}${contentToInsert}${contentAfterSelection}`
  } else {
    field.value += contentToInsert
  }
}

const htmlFromPasteEvent = event => {
  if (event.clipboardData) {
    return event.clipboardData.getData('text/html')
  }
}

const textFromPasteEvent = event => {
  if (event.clipboardData) {
    return event.clipboardData.getData('text/plain')
  } else if (window.clipboardData) {
    return window.clipboardData.getData('Text')
  }
}

const triggerPasteEvent = (element, eventName, detail) => {
  const params = { bubbles: false, cancelable: false, detail: detail || null }
  let event

  event = new window.CustomEvent(eventName, params)

  element.dispatchEvent(event)
}

const pasteListener = event => {
  const element = event.target

  const html = htmlFromPasteEvent(event)
  triggerPasteEvent(element, 'htmlpaste', html)

  const text = textFromPasteEvent(event)
  triggerPasteEvent(element, 'textpaste', text)

  if (html?.length) {
    const markdown = htmlToMarkdown(html)
    triggerPasteEvent(element, 'markdown', markdown)

    insertTextAtCursor(element, markdown)
    event.preventDefault()
  }
}

export { pasteListener, htmlToMarkdown }
