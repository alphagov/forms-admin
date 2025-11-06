// Largely based on [WAI's toolbar example](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/examples/toolbar/)
import h2Icon from '~/icons/markdown-editor-h2.svg?raw'
import h3Icon from '~/icons/markdown-editor-h3.svg?raw'
import bulletListIcon from '~/icons/markdown-editor-bullet-list.svg?raw'
import numberedListIcon from '~/icons/markdown-editor-numbered-list.svg?raw'
import linkIcon from '~/icons/markdown-editor-link.svg?raw'

const blockPrefixPattern = /^(## |### |\* |- |1. )/g

const addLink = (event, textArea) => {
  event.preventDefault()
  const { selection, selectionStart, selectionEnd } = getSelection(textArea)
  const blockPrefix = selection.match(blockPrefixPattern)?.[0] ?? ''
  const selectionWithoutPrefix = selection.replace(blockPrefix, '')
  const linkMarkdown = `${blockPrefix}[${
    selectionEnd === selectionStart ? 'Link text' : selectionWithoutPrefix
  }](https://www.gov.uk/link-text-url)`

  updateSelection({
    element: textArea,
    start: selectionStart,
    end: selectionEnd,
    updatedText: linkMarkdown
  })
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

    updateSelection({
      element: textArea,
      start: selectionStart,
      end: selectionEnd,
      updatedText: markdown,
      isBlock: true
    })
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
      callback: addH2,
      isHeading: true,
      icon: h2Icon
    },
    {
      identifier: 'h3',
      callback: addH3,
      isHeading: true,
      icon: h3Icon
    }
  ],
  [
    {
      identifier: 'link',
      callback: addLink,
      isHeading: false,
      icon: bulletListIcon
    }
  ],
  [
    {
      identifier: 'bullet-list',
      callback: addUnorderedList,
      isHeading: false,
      icon: numberedListIcon
    },
    {
      identifier: 'numbered-list',
      callback: addOrderedList,
      isHeading: false,
      icon: linkIcon
    }
  ]
]

const createToolbarForTextArea = textArea => {
  const toolbar = document.createElement('div')

  toolbar.classList.add('app-markdown-editor__toolbar')
  toolbar.setAttribute('aria-controls', textArea.id)
  toolbar.setAttribute('role', 'toolbar')
  toolbar.setAttribute('aria-label', 'Markdown formatting')

  return toolbar
}

const getButtonText = (identifier, i18n) => {
  const snakeCaseIdentifier = identifier.replaceAll('-', '_')
  return i18n[snakeCaseIdentifier]
}

const createButtonGroup = (
  configurationGroup,
  textArea,
  i18n,
  allowHeadings
) => {
  const buttonGroup = document.createElement('div')
  buttonGroup.classList.add('app-markdown-editor__toolbar-button-group')
  const buttons = configurationGroup
    .filter(button => allowHeadings || !button.isHeading)
    .map(buttonConfig =>
      createButton(
        textArea,
        getButtonText(buttonConfig.identifier, i18n),
        buttonConfig.callback,
        buttonConfig.identifier,
        buttonConfig.icon
      )
    )

  buttons.forEach(button => buttonGroup.appendChild(button))
  return buttonGroup
}

const createButton = (textArea, linkText, callback, identifier, icon) => {
  const button = document.createElement('button')
  button.innerHTML = `<span class='govuk-visually-hidden'>${linkText}</span>`

  const iconElement = createIconElement(icon)
  button.prepend(iconElement)

  button.classList.add(
    'govuk-button',
    'govuk-button--secondary',
    'app-markdown-editor__toolbar-button',
    `app-markdown-editor__toolbar-button--${identifier}`
  )

  button.setAttribute('title', linkText)
  addClickAndKeyboardEventListeners(textArea, button, callback)

  return button
}

const createIconElement = icon => {
  // create element from raw icon HTML
  const iconElement = new DOMParser().parseFromString(
    icon,
    'text/xml'
  ).firstChild

  // Hide element from assistive tech since the adjacent text conveys
  // the same meaning
  iconElement.setAttribute('aria-hidden', 'true')

  iconElement.classList.add('app-markdown-editor__toolbar-icon')

  return iconElement
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

const updateSelection = (
  { element, start, end, updatedText, isBlock } = { isBlock: false }
) => {
  let contentBeforeSelection = element.value.slice(0, start)

  if (isBlock && contentBeforeSelection.length > 0) {
    // remove any existing whitespace before the selection
    contentBeforeSelection = contentBeforeSelection.trimEnd()

    // add an empty line before the selection
    contentBeforeSelection += '\n\n'
  }

  element.value = `${contentBeforeSelection}${updatedText}${element.value.slice(
    end
  )}`
  element.setSelectionRange(
    contentBeforeSelection.length,
    contentBeforeSelection.length + updatedText.length
  )
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
 * @param {Boolean} allowHeadings - whether the markdown field allows headings
 */
const markdownEditorToolbar = (textArea, i18n, allowHeadings = true) => {
  const toolbar = createToolbarForTextArea(textArea)
  textArea.parentNode.insertBefore(toolbar, textArea)

  buttonGroupConfiguration
    .map(buttonConfiguration =>
      createButtonGroup(buttonConfiguration, textArea, i18n, allowHeadings)
    )
    .forEach(buttonGroup => toolbar.appendChild(buttonGroup))

  addButtonFocusEvents(toolbar.querySelectorAll('button'))
}

export default markdownEditorToolbar
