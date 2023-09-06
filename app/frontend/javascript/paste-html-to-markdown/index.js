// Adapted from the [Paste HTML to govspeak](https://github.com/alphagov/paste-html-to-govspeak) package.

import htmlToMarkdown from './html-to-markdown'
import replaceBulletCharacters from './replace-bullet-characters'

const insertTextAtCursor = (field, contentToInsert) => {
  const selectionStart = field.selectionStart
  const selectionEnd = field.selectionEnd
  if (selectionStart || selectionStart === '0' || selectionStart === 0) {
    const contentBeforeSelection = field.value.substring(0, selectionStart)
    const contentAfterSelection = field.value.substring(
      selectionEnd,
      field.value.length
    )
    field.value = `${contentBeforeSelection}${contentToInsert}${contentAfterSelection}`
  } else {
    field.value += contentToInsert
  }

  field.dispatchEvent(new window.InputEvent('input'))
}

const htmlFromPasteEvent = event => {
  return event.clipboardData.getData('text/html')
}

const textFromPasteEvent = event => {
  return event.clipboardData.getData('text/plain')
}

const triggerPasteEvent = (element, eventName, detail) => {
  const params = { bubbles: false, cancelable: false, detail: detail || null }
  const event = new window.CustomEvent(eventName, params)

  element.dispatchEvent(event)
}

const pasteListener = event => {
  if (event.clipboardData) {
    let contentToPaste
    event.preventDefault()
    const element = event.target

    const html = htmlFromPasteEvent(event)
    triggerPasteEvent(element, 'htmlpaste', html)

    const text = textFromPasteEvent(event)
    triggerPasteEvent(element, 'textpaste', text)

    if (html?.length) {
      const markdown = htmlToMarkdown(html)
      triggerPasteEvent(element, 'markdown', markdown)

      contentToPaste = markdown
    } else if (text?.length) {
      contentToPaste = replaceBulletCharacters(text)
    }
    insertTextAtCursor(element, contentToPaste)
  }
}

export { pasteListener, htmlToMarkdown }
