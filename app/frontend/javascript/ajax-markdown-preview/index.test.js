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
const setupDocument = () => {
  const i18n = JSON.stringify({
    preview_loading: 'Loading...',
    preview_error: 'There was an error'
  })

  const sourceHTML =
    '<textarea data-ajax-markdown-source="true">## This is a markdown heading</textarea>'
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

  describe('when the request returns the JSON response', () => {
    beforeEach(() => {
      global.fetch = mockFetch(jsonResponse)
      setupDocument()
    })

    test('preview is called on page load', async () => {
      expect(target.innerHTML).toBe(jsonResponse.preview_html)

      expect(global.fetch).toHaveBeenCalledTimes(1)
    })

    test('preview event fires if the user makes a change', () => {
      expect(global.fetch).toHaveBeenCalledTimes(1)

      const event = new window.Event('input')
      source.dispatchEvent(event)

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

  describe('when the AJAX request fails', () => {
    beforeEach(() => {
      global.fetch = jest.fn(async () => {
        return Promise.reject(new Error('API is down'))
      })
      setupDocument()
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

      setupDocument()
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
