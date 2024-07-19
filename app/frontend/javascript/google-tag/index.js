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
