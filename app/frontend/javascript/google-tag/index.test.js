/**
 * @vitest-environment jsdom
 */

import { installAnalyticsScript, sendPageViewEvent } from '../google-tag'
import { describe, afterEach, it, expect, beforeEach } from 'vitest'

describe('google_tag.mjs', () => {
  afterEach(() => {
    document.getElementsByTagName('html')[0].innerHTML = ''
  })

  describe('installAnalyticsScript()', () => {
    it('adds the google analytics script tag to the DOM', function () {
      installAnalyticsScript(window)
      expect(
        document.querySelectorAll(
          'script[src^="https://www.googletagmanager.com/gtm.js"]'
        ).length
      ).toBe(1)
    })

    describe('when google analytics is already present on the window', () => {
      beforeEach(() => {
        window.document.write = ''
        Object.defineProperty(window, 'ga', {
          writable: true,
          value: true
        })
      })

      it('does not add the google analytics script tag to the DOM', function () {
        installAnalyticsScript(window)
        expect(
          document.querySelectorAll(
            'script[src^="https://www.googletagmanager.com/gtm.js"]'
          ).length
        ).toBe(0)
      })
    })
  })

  describe('sendPageViewEvent()', () => {
    describe('when the dataLayer array is not already present on the window object', () => {
      beforeEach(() => {
        window.dataLayer = undefined
      })

      it('creates the dataLayer array and pushes a pageView event', function () {
        sendPageViewEvent()
        expect(window.dataLayer).toContainEqual({
          event: 'page_view',
          page_view: {
            location: window.location,
            referrer: '',
            schema_name: 'simple_schema',
            status_code: 200,
            title: ''
          }
        })
      })
    })
    describe('when the dataLayer array is already present on the window object', () => {
      const existingDataLayerObject = {
        data: 'Some existing data in the dataLayer'
      }

      beforeEach(() => {
        window.dataLayer = [existingDataLayerObject]
      })

      it('the existing dataLayer content is preserved', function () {
        sendPageViewEvent()
        expect(window.dataLayer).toContainEqual(existingDataLayerObject)
      })

      it('the pageView event is pushed to the dataLayer', function () {
        sendPageViewEvent()
        expect(window.dataLayer).toContainEqual({
          event: 'page_view',
          page_view: {
            location: window.location,
            referrer: '',
            schema_name: 'simple_schema',
            status_code: 200,
            title: ''
          }
        })
      })
    })
  })
})
