/**
 * @vitest-environment jsdom
 */

import {
  installAnalyticsScript,
  sendPageViewEvent,
  attachExternalLinkTracker,
  setDefaultConsent,
  attachQuestionXsRoutesTracker
} from '../google-tag'
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

  describe('setDefaultConsent()', () => {
    describe('when the dataLayer array is not already present on the window object', () => {
      beforeEach(() => {
        window.dataLayer = undefined
      })

      it('creates the dataLayer array and sets the default consent to "granted"', function () {
        setDefaultConsent()
        expect(window.dataLayer).toContainEqual([
          'consent',
          'default',
          {
            ad_storage: 'denied',
            analytics_storage: 'granted'
          }
        ])
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
        setDefaultConsent()
        expect(window.dataLayer).toContainEqual(existingDataLayerObject)
      })

      it('sets the default consent to "granted"', function () {
        setDefaultConsent()
        expect(window.dataLayer).toContainEqual([
          'consent',
          'default',
          {
            ad_storage: 'denied',
            analytics_storage: 'granted'
          }
        ])
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

  describe('attachExternalLinkTracker()', () => {
    const targetLinkText = 'A link to example.com'
    const targetLinkUrl = 'http://example.com/'

    const existingDataLayerObject = {
      data: 'Some existing data in the dataLayer'
    }

    const preventDefault = event => {
      event.preventDefault()
    }

    beforeEach(() => {
      window.document.body.innerHTML = `<a href="${targetLinkUrl}">${targetLinkText}</a>`
      window.dataLayer = [existingDataLayerObject]

      // stop link clicks from navigating, since jsdom can't do navigation
      document.querySelector('a').addEventListener('click', preventDefault)
    })

    afterEach(() => {
      document.querySelector('a').removeEventListener('click', preventDefault)
    })

    it('the existing dataLayer content is preserved', function () {
      attachExternalLinkTracker()
      document.querySelector('a').click()
      expect(window.dataLayer).toContainEqual(existingDataLayerObject)
    })

    it('the pageView event is pushed to the dataLayer', function () {
      attachExternalLinkTracker()
      document.querySelector('a').click()
      expect(window.dataLayer).toContainEqual({
        event: 'event_data',
        event_data: {
          event_name: 'navigation',
          external: true,
          method: 'primary click',
          text: targetLinkText,
          type: 'generic link',
          url: targetLinkUrl
        }
      })
    })
  })

  describe('attachQuestionXsRoutesTracker()', () => {
    const windowLocation = window.location
    const existingDataLayerObject = {
      data: 'Some existing data in the dataLayer'
    }

    beforeEach(() => {
      window.dataLayer = [existingDataLayerObject]
    })

    afterEach(() => {
      window.location = windowLocation
    })

    describe('when the path matches the required routes#show regex', () => {
      const showRoutesPath = '/forms/123/pages/456/routes'

      beforeEach(() => {
        Object.defineProperty(window, 'location', {
          value: new URL(`http://example.com${showRoutesPath}`),
          writable: true
        })
      })

      it('creates pushes a routes_page_view event to the datalayer', () => {
        attachQuestionXsRoutesTracker()
        expect(window.dataLayer).toContainEqual({
          event: 'event_data',
          event_data: {
            event_name: 'question_routes_page_viewed',
            url: window.location,
            text: 'Question routes page viewed'
          }
        })
      })

      describe('when the path does not match the required routes#show regex', () => {
        const showRoutesPath = '/forms/123/pages/456/routes/delete'

        beforeEach(() => {
          Object.defineProperty(window, 'location', {
            value: new URL(`http://example.com${showRoutesPath}`),
            writable: true
          })
        })

        it('the routes_page_view event is not pushed to the dataLayer', () => {
          attachQuestionXsRoutesTracker()
          expect(window.dataLayer).toEqual([existingDataLayerObject])
        })
      })
    })
  })
})
