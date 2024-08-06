export function installAnalyticsScript (global) {
  const GTAG_ID = 'GTM-MFJWJNW'
  if (!window.ga) {
    ;(function (w, d, s, l, i) {
      w[l] = w[l] || []
      w[l].push({
        'gtm.start': new Date().getTime(),
        event: 'gtm.js'
      })

      const j = d.createElement(s)
      const dl = l !== 'dataLayer' ? '&l=' + l : ''

      j.async = true
      j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i + dl
      document.head.appendChild(j)
    })(global, document, 'script', 'dataLayer', GTAG_ID)
  }
}

export function setDefaultConsent () {
  window.dataLayer = window.dataLayer || []
  window.dataLayer.push([
    'consent',
    'default',
    {
      ad_storage: 'denied',
      analytics_storage: 'granted'
    }
  ])
}

export function sendPageViewEvent () {
  // Ideally this should be placed above the GTM container snippet and early within the <head> tags
  window.dataLayer = window.dataLayer || []
  window.dataLayer.push({
    // Where a property value is not available, set it as undefined
    event: 'page_view',
    page_view: {
      location: document.location,
      referrer: document.referrer,
      schema_name: 'simple_schema',
      status_code: 200,
      title: document.title
    }
  })
}

export function attachExternalLinkTracker () {
  const externalLinks = document.querySelectorAll(
    'a[href^="http"], a[href^="https"]'
  )
  externalLinks.forEach(function (externalLink) {
    externalLink.addEventListener('click', function (event) {
      const target = event.target
      window.dataLayer.push({
        event: 'event_data',
        event_data: {
          event_name: 'navigation',
          external: true,
          method: 'primary click',
          text: target.textContent,
          type: 'generic link',
          url: target.href
        }
      })
    })
  })
}
