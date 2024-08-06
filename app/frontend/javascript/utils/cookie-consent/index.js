import { setDefaultConsent } from '../../google-tag'

export const COOKIE_NAME = 'analytics_consent'

export function saveConsentStatus (consent, date) {
  date = date || new Date()
  date.setTime(date.getTime() + 365 * 24 * 60 * 60 * 1000)
  document.cookie =
    COOKIE_NAME + '=' + consent + '; expires=' + date.toGMTString() + '; path=/'
  setDefaultConsent()
}
