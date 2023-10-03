/**
 * @jest-environment jsdom
 */

import 'regenerator-runtime/runtime'
import ajaxMarkdownPreview from '.'

import {
  mockFetch,
  mockFetchWithDelay,
  flushPromises
} from '../../test/test-helpers'

let source, target

const jsonResponse = {
  preview_html: '<h2 class="govuk-heading-m">This is a heading</h2>',
  errors: []
}

const jsonResponseWithError = {
  preview_html: '<p>This is a level one heading</p>',
  errors: [
    'Guidance text can only contain formatting for links, subheadings (##), bulleted lists (*), or numbered lists (1.)'
  ]
}

const updateMarkdown = markdownContent => {
  source.value = markdownContent
  const event = new window.Event('input')
  source.dispatchEvent(event)
}

const generateSourceHTML = (markdownContent, includeServerSideError) => {
  if (includeServerSideError) {
    return `<div class="govuk-form-group govuk-form-group--error">
        <p class="govuk-error-message" id="markdown-field-error">
          <span class="govuk-visually-hidden">Error: </span>Guidance text can only contain formatting for links, subheadings (##), bulleted lists (*), or numbered lists (1.)
        </p>
        <textarea aria-describedby="markdown-field-error" data-ajax-markdown-source="true">${markdownContent}</textarea>
      </div>`
  } else {
    return `<div class="govuk-form-group"><textarea data-ajax-markdown-source="true">${markdownContent}</textarea></div>`
  }
}

const setupDocument = (markdownContent, includeServerSideError = false) => {
  const i18n = JSON.stringify({
    preview_loading: 'Loading...',
    preview_error: 'There was an error'
  })

  const sourceHTML = generateSourceHTML(markdownContent, includeServerSideError)
  const targetHTML =
    '<div data-ajax-markdown-target><p>Some old preview content</p></div>'
  document.body.innerHTML = `<div data-module="ajax-markdown-preview" data-ajax-markdown-endpoint="/endpoint" data-i18n='${i18n}'>
    ${sourceHTML}
    ${targetHTML}
    </div>
  `
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

  source = document.querySelector('[data-ajax-markdown-source]')
  target = document.querySelector('[data-ajax-markdown-target]')
}

describe('AJAX Markdown preview', () => {
  beforeEach(() => {
    jest.useFakeTimers()
  })

  afterEach(() => {
    jest.clearAllMocks()
    jest.runOnlyPendingTimers()
    jest.useRealTimers()
  })

  describe('when the request returns the JSON response with no errors', () => {
    beforeEach(() => {
      global.fetch = mockFetch(jsonResponse)
      setupDocument('## This is a markdown heading')
    })

    test('preview is called on page load', async () => {
      expect(target.innerHTML).toBe(jsonResponse.preview_html)

      expect(global.fetch).toHaveBeenCalledTimes(1)
    })

    test('preview event fires if the user makes a change', () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)

      updateMarkdown()

      jest.runAllTimers()

      expect(global.fetch).toHaveBeenCalledTimes(2)
    })

    test('preview event updates the content correctly', async () => {
      target.innerHTML = ''
      const event = new window.Event('input')
      source.dispatchEvent(event)

      jest.runAllTimers()
      await flushPromises()

      expect(target.innerHTML).toBe(jsonResponse.preview_html)
    })

    test('preview event only fires once if the user makes multiple changes in quick succession', () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)
      ;[...Array(100)].forEach(() => {
        const event = new window.Event('input')
        source.dispatchEvent(event)
      })

      jest.runAllTimers()

      expect(global.fetch).toHaveBeenCalledTimes(2)
    })
  })

  describe('when the request returns the JSON response with errors', () => {
    describe('when there is no server-side error message present', () => {
      beforeEach(() => {
        global.fetch = mockFetch(jsonResponseWithError)
        setupDocument('# This is a level one heading')
      })

      test('an error message is displayed', () => {
        expect(document.querySelector('.govuk-error-message').textContent).toBe(
          `Error: ${jsonResponseWithError.errors[0]}`
        )
      })

      test('the error message is associated with the textarea using aria-described', () => {
        expect(source.getAttribute('aria-describedby')).toContain(
          document.querySelector('.govuk-error-message').getAttribute('id')
        )
      })

      test('the form group has the error class', () => {
        expect(
          document.querySelectorAll('.govuk-form-group--error')
        ).toHaveLength(1)
      })

      describe('when the user fixes the error', () => {
        beforeEach(async () => {
          global.fetch = mockFetch(jsonResponse)
          updateMarkdown('## This is a level two heading')

          jest.runAllTimers()
          await flushPromises()
        })

        test('the error message is removed', () => {
          expect(
            document.querySelector('.govuk-error-message').textContent
          ).toBe('')
        })

        test('the form group does not have the error class', () => {
          expect(
            document.querySelectorAll('.govuk-form-group--error')
          ).toHaveLength(0)
        })
      })
    })

    describe('when a server-side error is already present', () => {
      beforeEach(() => {
        global.fetch = mockFetch(jsonResponseWithError)
        setupDocument('# This is a level one heading', true)
      })

      test('an error message is displayed', () => {
        expect(document.querySelector('.govuk-error-message').textContent).toBe(
          `Error: ${jsonResponseWithError.errors[0]}`
        )
      })

      test('the error message is associated with the textarea using aria-described', () => {
        expect(source.getAttribute('aria-describedby')).toContain(
          document.querySelector('.govuk-error-message').getAttribute('id')
        )
      })

      test('the form group has the error class', () => {
        expect(
          document.querySelectorAll('.govuk-form-group--error')
        ).toHaveLength(1)
      })

      describe('when the user fixes the error', () => {
        beforeEach(async () => {
          global.fetch = mockFetch(jsonResponse)
          updateMarkdown('## This is a level two heading')

          jest.runAllTimers()
          await flushPromises()
        })

        test('the error message is removed', () => {
          expect(
            document.querySelector('.govuk-error-message').textContent
          ).toBe('')
        })

        test('the form group does not have the error class', () => {
          expect(
            document.querySelectorAll('.govuk-form-group--error')
          ).toHaveLength(0)
        })
      })
    })
  })

  describe('when the AJAX request fails', () => {
    beforeEach(() => {
      global.fetch = jest.fn(async () => {
        return Promise.reject(new Error('API is down'))
      })
      setupDocument('## This is a markdown heading')
    })

    test('the error message is displayed', () => {
      expect(target.innerHTML).toBe(
        '<p>There was an error</p><button class="govuk-button govuk-button--secondary">Retry preview</button>'
      )
      const ariaLiveRegion = document.querySelector(
        '.app-markdown-editor__notification-area'
      )
      expect(ariaLiveRegion.getAttribute('aria-busy')).toBe('false')
    })

    test('the retry button resends the request', () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)

      const retryButton = target.querySelector('button')
      retryButton.click()

      expect(global.fetch).toHaveBeenCalledTimes(2)
    })
  })

  describe('when the request is loading', () => {
    beforeEach(() => {
      global.fetch = mockFetchWithDelay(jsonResponse, 500)

      setupDocument('## This is a markdown heading')
    })

    test('Loading text is displayed before the response arrives', async () => {
      expect(target.innerHTML).toBe('<p>Loading...</p>')

      jest.advanceTimersByTime(500)
      await flushPromises()

      expect(target.innerHTML).toBe(jsonResponse.preview_html)
    })

    test('message is pushed to aria-live region when the page loads', async () => {
      const ariaLiveRegion = document.querySelector(
        '.app-markdown-editor__notification-area'
      )
      expect(ariaLiveRegion.getAttribute('aria-busy')).toBe('true')

      jest.advanceTimersByTime(500)
      await flushPromises()

      expect(ariaLiveRegion.getAttribute('aria-busy')).toBe('false')
    })
  })
})
