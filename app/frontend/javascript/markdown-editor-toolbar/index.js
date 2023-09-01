// Largely based on [WAI's toolbar example](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/examples/toolbar/)

const blockPrefixPattern = /^(## |### |\* |- |1. )/g

const addLink = (event, textArea) => {
  event.preventDefault()
  const { selection, selectionStart, selectionEnd } = getSelection(textArea)
  const blockPrefix = selection.match(blockPrefixPattern)?.[0] ?? ''
  const selectionWithoutPrefix = selection.replace(blockPrefix, '')
  const linkMarkdown = `${blockPrefix}[${
    selectionEnd === selectionStart ? 'Link text' : selectionWithoutPrefix
  }](https://www.gov.uk/link-text-url)`
  updateSelection(textArea, selectionStart, selectionEnd, linkMarkdown)
}

// You can only have one block style at a time, and it's always applied to the whole line.
// Use this for currying when adding new block-level formatting options.
const addBlockElement = transform => {
  return (event, textArea) => {
    event.preventDefault()
    const { selection, selectionStart, selectionEnd } =
      getFullLineForSelection(textArea)
    const trimmedSelection = removeBlockPrefix(selection)
    const markdown = transform(trimmedSelection)
    updateSelection(textArea, selectionStart, selectionEnd, markdown)
  }
}

const addH2 = addBlockElement(
  selection => `## ${selection.length ? selection : 'Heading text'}`
)

const addH3 = addBlockElement(
  selection => `### ${selection.length ? selection : 'Heading text'}`
)

const addOrderedList = addBlockElement(
  selection => `1. ${selection.length ? selection : 'List item'}`
)

const addUnorderedList = addBlockElement(
  selection => `* ${selection.length ? selection : 'List item'}`
)

const buttonGroupConfiguration = [
  [
    {
      identifier: 'h2',
      callback: addH2
    },
    {
      identifier: 'h3',
      callback: addH3
    }
  ],
  [{ identifier: 'link', callback: addLink }],
  [
    {
      identifier: 'bullet-list',
      callback: addUnorderedList
    },
    {
      identifier: 'numbered-list',
      callback: addOrderedList
    }
  ]
]

const createToolbarForTextArea = textArea => {
  const toolbar = document.createElement('div')

  toolbar.classList.add('app-markdown-editor-toolbar')
  toolbar.setAttribute('aria-controls', textArea.id)
  toolbar.setAttribute('role', 'toolbar')
  toolbar.setAttribute('aria-label', 'Markdown formatting')

  return toolbar
}

const getButtonText = (identifier, i18n) => {
  const snakeCaseIdentifier = identifier.replaceAll('-', '_')
  return i18n[snakeCaseIdentifier]
}

const createButtonGroup = (configurationGroup, textArea, i18n) => {
  const buttonGroup = document.createElement('div')
  buttonGroup.classList.add('app-markdown-editor-toolbar__button-group')
  const buttons = configurationGroup.map(buttonConfig =>
    createButton(
      textArea,
      getButtonText(buttonConfig.identifier, i18n),
      buttonConfig.callback,
      buttonConfig.identifier
    )
  )

  buttons.forEach(button => buttonGroup.appendChild(button))
  return buttonGroup
}

const createButton = (textArea, linkText, callback, identifier) => {
  const button = document.createElement('button')
  button.innerHTML = `<span class='govuk-visually-hidden'>${linkText}</span>`
  button.classList.add(
    'govuk-button',
    'govuk-button--secondary',
    'app-markdown-editor-toolbar__button',
    `app-markdown-editor-toolbar__button--${identifier}`
  )
  button.setAttribute('title', linkText)
  addClickAndKeyboardEventListeners(textArea, button, callback)
  return button
}

const getSelection = element => {
  const selectionStart = element.selectionStart
  const selectionEnd = element.selectionEnd
  const selection = element.value.substring(selectionStart, selectionEnd)

  return { selection, selectionStart, selectionEnd }
}

const getFullLineForSelection = element => {
  const {
    selectionStart: initialSelectionStart,
    selectionEnd: initialSelectionEnd
  } = getSelection(element)
  const linesBeforeInitialSelection = element.value
    .substr(0, initialSelectionStart)
    .split('\n')
  const prefix =
    linesBeforeInitialSelection[linesBeforeInitialSelection.length - 1]

  const linesAfterInitialSelection = element.value
    .substr(initialSelectionEnd, element.value.length - 1)
    .split('\n')
  const suffix = linesAfterInitialSelection[0]

  const selectionStart = initialSelectionStart - prefix.length
  const selectionEnd = initialSelectionEnd + suffix.length
  const selection = element.value.substring(selectionStart, selectionEnd)

  return { selection, selectionStart, selectionEnd }
}

const updateSelection = (element, start, end, updatedText) => {
  element.value = `${element.value.slice(
    0,
    start
  )}${updatedText}${element.value.slice(end)}`
  element.setSelectionRange(start, start + updatedText.length)
  element.dispatchEvent(new window.InputEvent('input'))
}
const removeBlockPrefix = text => text.trim().replace(blockPrefixPattern, '')

const addClickAndKeyboardEventListeners = (textArea, element, callback) => {
  element.addEventListener('click', event => {
    callback(event, textArea)
  })
  element.addEventListener('keyup', event => {
    const element = event.target
    if (
      [' ', 'Enter'].includes(event.key) &&
      element instanceof window.HTMLElement &&
      element.getAttribute('role') === 'button'
    ) {
      callback(event, textArea)
    }
  })
}

const addButtonFocusEvents = buttons => {
  buttons.forEach((button, index) => {
    button.setAttribute('tabindex', index === 0 ? 0 : -1)

    if (index > 0) {
      button.addEventListener('keyup', event => {
        if (event.key === 'ArrowLeft') {
          button.setAttribute('tabindex', -1)
          buttons[index - 1].setAttribute('tabindex', 0)
          buttons[index - 1].focus()
        }
      })
    }
    if (index !== buttons.length - 1) {
      button.addEventListener('keyup', event => {
        if (event.key === 'ArrowRight') {
          button.setAttribute('tabindex', -1)
          buttons[index + 1].setAttribute('tabindex', 0)
          buttons[index + 1].focus()
        }
      })
    }
  })
}

/**
 * Adds a copy button to an element.
 * @param {HTMLElement} textArea - The textarea whose contents are being formatted by the toolbar.
 * @param {Object} i18n - An object containing translations for the toolbar button text.
 */
const markdownEditorToolbar = (textArea, i18n) => {
  const toolbar = createToolbarForTextArea(textArea)
  textArea.parentNode.insertBefore(toolbar, textArea)

  buttonGroupConfiguration
    .map(buttonConfiguration =>
      createButtonGroup(buttonConfiguration, textArea, i18n)
    )
    .forEach(buttonGroup => toolbar.appendChild(buttonGroup))

  addButtonFocusEvents(toolbar.querySelectorAll('button'))
}

export default markdownEditorToolbar
