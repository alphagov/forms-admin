/**
 * @vitest-environment jsdom
 */

import 'regenerator-runtime/runtime'
import ajaxMarkdownPreview from '.'

import {
  mockFetch,
  mockFetchWithDelay,
  mockFetchWithServerError
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
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.runOnlyPendingTimers()
    vi.useRealTimers()
  })

  describe('when the request returns the JSON response with no errors', () => {
    beforeEach(() => {
      global.fetch = mockFetch(jsonResponse)
      setupDocument('## This is a markdown heading')
    })

    test('preview is called on page load', async () => {
      expect(target.innerHTML).toBe(jsonResponse.preview_html)

      expect(global.fetch).toHaveBeenCalledWith('/endpoint', {
        body: '{"markdown":"## This is a markdown heading"}',
        cache: 'no-cache',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': undefined
        },
        method: 'POST',
        mode: 'same-origin',
        redirect: 'follow',
        referrerPolicy: 'same-origin'
      })
      expect(global.fetch).toHaveBeenCalledTimes(1)
    })

    test('preview event fires if the user makes a change', async () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)

      updateMarkdown()

      await vi.runAllTimersAsync()

      expect(global.fetch).toHaveBeenCalledTimes(2)
    })

    test('preview event updates the content correctly', async () => {
      target.innerHTML = ''
      const event = new window.Event('input')
      source.dispatchEvent(event)

      await vi.runAllTimersAsync()

      expect(target.innerHTML).toBe(jsonResponse.preview_html)
    })

    test('preview event only fires once if the user makes multiple changes in quick succession', async () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)
      ;[...Array(100)].forEach(() => {
        const event = new window.Event('input')
        source.dispatchEvent(event)
      })

      await vi.runAllTimersAsync()

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

          await vi.runAllTimersAsync()
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

          await vi.runAllTimersAsync()
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
      global.fetch = mockFetchWithServerError()

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

      await vi.advanceTimersByTimeAsync(500)

      expect(target.innerHTML).toBe(jsonResponse.preview_html)
    })

    test('message is pushed to aria-live region when the page loads', async () => {
      const ariaLiveRegion = document.querySelector(
        '.app-markdown-editor__notification-area'
      )
      expect(ariaLiveRegion.getAttribute('aria-busy')).toBe('true')

      await vi.advanceTimersByTimeAsync(500)

      expect(ariaLiveRegion.getAttribute('aria-busy')).toBe('false')
    })
  })

  describe('when there are multiple instances on the page', () => {
    let source1, target1, target2

    const jsonResponse1 = {
      preview_html: '<p>Preview for editor 1</p>',
      errors: []
    }

    const jsonResponse2 = {
      preview_html: '<p>Preview for editor 2</p>',
      errors: []
    }

    const setupMultipleEditors = () => {
      const i18n = JSON.stringify({
        preview_loading: 'Loading...',
        preview_error: 'There was an error'
      })

      document.body.innerHTML = `
        <div data-module="ajax-markdown-preview" data-ajax-markdown-endpoint="/endpoint1" data-i18n='${i18n}'>
          <div class="govuk-form-group">
            <textarea id="editor1" data-ajax-markdown-source="true">Content for editor 1</textarea>
          </div>
          <div data-ajax-markdown-target><p>Old preview 1</p></div>
        </div>
        <div data-module="ajax-markdown-preview" data-ajax-markdown-endpoint="/endpoint2" data-i18n='${i18n}'>
          <div class="govuk-form-group">
            <textarea id="editor2" data-ajax-markdown-source="true">Content for editor 2</textarea>
          </div>
          <div data-ajax-markdown-target><p>Old preview 2</p></div>
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

      const editors = document.querySelectorAll(
        '[data-module="ajax-markdown-preview"]'
      )
      source1 = editors[0].querySelector('[data-ajax-markdown-source]')
      target1 = editors[0].querySelector('[data-ajax-markdown-target]')
      target2 = editors[1].querySelector('[data-ajax-markdown-target]')
    }

    beforeEach(() => {
      // Mock fetch to return different responses based on endpoint
      global.fetch = vi.fn(url => {
        const response = url === '/endpoint1' ? jsonResponse1 : jsonResponse2
        return Promise.resolve({
          json: () => Promise.resolve(response)
        })
      })

      setupMultipleEditors()
    })

    test('each instance has its own preview target', () => {
      expect(target1.innerHTML).toBe(jsonResponse1.preview_html)
      expect(target2.innerHTML).toBe(jsonResponse2.preview_html)
    })

    test('each instance calls its own endpoint', () => {
      expect(global.fetch).toHaveBeenCalledWith(
        '/endpoint1',
        expect.objectContaining({
          body: expect.stringContaining('Content for editor 1')
        })
      )
      expect(global.fetch).toHaveBeenCalledWith(
        '/endpoint2',
        expect.objectContaining({
          body: expect.stringContaining('Content for editor 2')
        })
      )
    })

    test('updating one editor does not affect the other', async () => {
      // Clear the initial calls
      global.fetch.mockClear()

      // Update only the first editor
      source1.value = 'Updated content for editor 1'
      source1.dispatchEvent(new window.Event('input'))

      await vi.runAllTimersAsync()

      // Only endpoint1 should be called
      expect(global.fetch).toHaveBeenCalledTimes(1)
      expect(global.fetch).toHaveBeenCalledWith(
        '/endpoint1',
        expect.objectContaining({
          body: expect.stringContaining('Updated content for editor 1')
        })
      )

      // Target 2 should still have its original content
      expect(target2.innerHTML).toBe(jsonResponse2.preview_html)
    })

    test('each instance has its own live region', () => {
      const liveRegions = document.querySelectorAll(
        '.app-markdown-editor__notification-area'
      )
      expect(liveRegions).toHaveLength(2)
    })

    test('each instance has its own error area', () => {
      const errorAreas = document.querySelectorAll(
        '.app-markdown-editor__error-message'
      )
      expect(errorAreas).toHaveLength(2)
    })
  })
})
