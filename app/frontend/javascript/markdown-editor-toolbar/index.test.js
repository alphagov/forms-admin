/**
 * @vitest-environment jsdom
 */
import markdownEditorToolbar from '.'
import { getByText } from '@testing-library/dom'

const selectText = (textArea, text) => {
  textArea.setSelectionRange(
    textArea.value.indexOf(text),
    textArea.value.indexOf(text) + text.length
  )
}

let toolbar
let textArea

const prefixes = ['## ', '### ', '* ', '- ', '1. ']

describe('Markdown toolbar', () => {
  beforeEach(() => {
    const textAreaContent = `

    Grid references

    There are two main types of grid reference:
    10 figure grid references
    6 figure grid references

    How to find a 10 figure grid reference

    In order to find the relevant grid reference you should do the following:

    Go to the Grid Reference Finder website
    Search for your location by postcode or using the other search fields
    Click on the location

    The 10 figure grid reference is the first reference shown, in an orange font.


    `

    const i18n = JSON.stringify({
      h2: 'Add a second-level heading',
      h3: 'Add a third-level heading',
      link: 'Add a link',
      bullet_list: 'Add a bulleted list',
      numbered_list: 'Add a numbered list'
    })

    document.body.innerHTML = `
      <textarea data-module="markdown-editor" data-i18n='${i18n}'>${textAreaContent}</textarea>
    `

    document
      .querySelectorAll('[data-module="markdown-editor"]')
      .forEach(element => {
        markdownEditorToolbar(
          element,
          JSON.parse(element.getAttribute('data-i18n'))
        )
      })
    toolbar = document.querySelector('.app-markdown-editor__toolbar')
    textArea = document.querySelector('textarea')
  })

  test('toolbar is created', () => {
    expect(toolbar).not.toBeNull()
  })

  test('toolbar has the correct label', () => {
    expect(toolbar.getAttribute('aria-label')).toBe('Markdown formatting')
  })

  test('toolbar has the required buttons', () => {
    ;[
      'Add a second-level heading',
      'Add a third-level heading',
      'Add a link',
      'Add a bulleted list',
      'Add a numbered list'
    ].forEach(buttonText => {
      const button = getByText(document, buttonText)
      expect(button).not.toBeNull()
    })
  })

  describe('arrow key navigation', () => {
    const rightArrowPressEvent = new window.KeyboardEvent('keyup', {
      key: 'ArrowRight',
      code: 'ArrowRight'
    })
    const leftArrowPressEvent = new window.KeyboardEvent('keyup', {
      key: 'ArrowLeft',
      code: 'ArrowLeft'
    })

    test('user can use the right arrow key to navigate to the next button', () => {
      const buttons = toolbar.querySelectorAll('button')

      buttons[0].focus()
      buttons[0].dispatchEvent(rightArrowPressEvent)
      expect(document.activeElement).toBe(buttons[1])
    })

    test('user can use the left arrow key to navigate to the previous button', () => {
      const buttons = toolbar.querySelectorAll('button')

      buttons[buttons.length - 1].focus()
      buttons[1].dispatchEvent(leftArrowPressEvent)
      expect(document.activeElement).toBe(buttons[0])
    })

    test('pressing left on the first button does not wrap to the last button', () => {
      const buttons = toolbar.querySelectorAll('button')

      buttons[0].focus()
      buttons[0].dispatchEvent(leftArrowPressEvent)
      expect(document.activeElement).toBe(buttons[0])
    })

    test('pressing right on the last button does not wrap to the first button', () => {
      const buttons = toolbar.querySelectorAll('button')

      buttons[buttons.length - 1].focus()
      buttons[buttons.length - 1].dispatchEvent(rightArrowPressEvent)
      expect(document.activeElement).toBe(buttons[buttons.length - 1])
    })
  })

  describe('second-level heading button', () => {
    test('formats the whole line if only a part of the line is selected', () => {
      selectText(textArea, 'references')

      getByText(toolbar, 'Add a second-level heading').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('## Grid references')
    })

    test('adds placeholder text if there is no text on the selected line', () => {
      textArea.setSelectionRange(
        textArea.value.length - 1,
        textArea.value.length - 1
      )

      getByText(toolbar, 'Add a second-level heading').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('## Heading text')
    })

    test('removes the existing prefix', () => {
      prefixes.forEach(prefix => {
        textArea.value = `${prefix}This is an item with an existing markdown block style`
        selectText(
          textArea,
          'This is an item with an existing markdown block style'
        )

        getByText(toolbar, 'Add a second-level heading').click()

        expect(
          textArea.value.substring(
            textArea.selectionStart,
            textArea.selectionEnd
          )
        ).toBe('## This is an item with an existing markdown block style')
      })
    })
  })

  describe('third-level heading button', () => {
    test('formats the whole line if only a part of the line is selected', () => {
      selectText(textArea, 'find a 10 figure grid reference')

      getByText(toolbar, 'Add a third-level heading').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('### How to find a 10 figure grid reference')
    })

    test('adds placeholder text if there is no text on the selected line', () => {
      textArea.setSelectionRange(
        textArea.value.length - 1,
        textArea.value.length - 1
      )

      getByText(toolbar, 'Add a third-level heading').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('### Heading text')
    })

    test('removes the existing prefix', () => {
      prefixes.forEach(prefix => {
        textArea.value = `${prefix}This is an item with an existing markdown block style`
        selectText(
          textArea,
          'This is an item with an existing markdown block style'
        )

        getByText(toolbar, 'Add a third-level heading').click()

        expect(
          textArea.value.substring(
            textArea.selectionStart,
            textArea.selectionEnd
          )
        ).toBe('### This is an item with an existing markdown block style')
      })
    })
  })

  describe('add numbered list button', () => {
    test('formats the whole line if only a part of the line is selected', () => {
      selectText(textArea, 'Grid Reference Finder')

      getByText(toolbar, 'Add a numbered list').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('1. Go to the Grid Reference Finder website')
    })

    test('adds placeholder text if there is no text on the selected line', () => {
      textArea.setSelectionRange(
        textArea.value.length - 1,
        textArea.value.length - 1
      )

      getByText(toolbar, 'Add a numbered list').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('1. List item')
    })

    test('removes the existing prefix', () => {
      prefixes.forEach(prefix => {
        textArea.value = `${prefix}This is an item with an existing markdown block style`
        selectText(
          textArea,
          'This is an item with an existing markdown block style'
        )

        getByText(toolbar, 'Add a numbered list').click()

        expect(
          textArea.value.substring(
            textArea.selectionStart,
            textArea.selectionEnd
          )
        ).toBe('1. This is an item with an existing markdown block style')
      })
    })
  })

  describe('add bullet list button', () => {
    test('formats the whole line if only a part of the line is selected', () => {
      selectText(textArea, 'Grid Reference Finder')

      getByText(toolbar, 'Add a bulleted list').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('* Go to the Grid Reference Finder website')
    })

    test('adds placeholder text if there is no text on the selected line', () => {
      textArea.setSelectionRange(
        textArea.value.length - 1,
        textArea.value.length - 1
      )

      getByText(toolbar, 'Add a bulleted list').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('* List item')
    })

    test('removes the existing prefix', () => {
      prefixes.forEach(prefix => {
        textArea.value = `${prefix}This is an item with an existing markdown block style`
        selectText(
          textArea,
          'This is an item with an existing markdown block style'
        )

        getByText(toolbar, 'Add a bulleted list').click()

        expect(
          textArea.value.substring(
            textArea.selectionStart,
            textArea.selectionEnd
          )
        ).toBe('* This is an item with an existing markdown block style')
      })
    })
  })

  describe('add link button', () => {
    test('formats the selection', () => {
      selectText(textArea, 'Grid Reference Finder website')

      getByText(toolbar, 'Add a link').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe(
        '[Grid Reference Finder website](https://www.gov.uk/link-text-url)'
      )
    })

    test('adds placeholder text if there is no text on the selected line', () => {
      textArea.setSelectionRange(
        textArea.value.length - 1,
        textArea.value.length - 1
      )

      getByText(toolbar, 'Add a link').click()

      expect(
        textArea.value.substring(textArea.selectionStart, textArea.selectionEnd)
      ).toBe('[Link text](https://www.gov.uk/link-text-url)')
    })

    test('excludes the existing prefix from the link', () => {
      prefixes.forEach(prefix => {
        textArea.value = `${prefix}This is an item with an existing markdown block style`
        selectText(textArea, textArea.value)

        getByText(toolbar, 'Add a link').click()

        expect(
          textArea.value.substring(
            textArea.selectionStart,
            textArea.selectionEnd
          )
        ).toBe(
          `${prefix}[This is an item with an existing markdown block style](https://www.gov.uk/link-text-url)`
        )
      })
    })
  })
})
