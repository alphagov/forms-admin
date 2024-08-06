/**
 * @vitest-environment jsdom
 */

import { saveConsentStatus } from './index.js'
import { describe, beforeEach, afterEach, it, expect } from 'vitest'

describe('Cookie', () => {
  afterEach(() => {
    // delete all cookies between tests
    const cookies = document.cookie.split(';')

    cookies.forEach(function (cookie) {
      const name = cookie.split('=')[0]
      document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT'
    })
  })

  describe('saveConsentStatus', () => {
    beforeEach(() => {
      Object.defineProperty(window.document, 'cookie', {
        writable: true,
        value: ''
      })
    })

    it('writes the correct value to the cookie', () => {
      const fixedTestDate = new Date(2023, 1, 1, 0, 0, 0, 0)
      saveConsentStatus(true, fixedTestDate)
      expect(window.document.cookie).toBe(
        'analytics_consent=true; expires=Thu, 01 Feb 2024 00:00:00 GMT; path=/'
      )
    })
  })
})
