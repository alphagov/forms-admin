import debounce from '../utils/debounce'

const store = {
  target: null,
  source: null,
  failureText: null,
  loadingText: null,
  authenticityToken: null,
  csrfToken: null,
  liveRegion: null
}

const setLoadingStatus = () => {
  store.liveRegion.setAttribute('aria-busy', 'true')
  store.target.innerHTML = `<p>${store.loadingText}</p>`
}

const setFailureStatus = () => {
  store.target.innerHTML = `<p>${store.failureText}</p>`
  const retryButton = document.createElement('button')
  retryButton.classList.add('govuk-button', 'govuk-button--secondary')
  retryButton.innerHTML = 'Retry preview'
  addEventListeners(retryButton, manuallyTriggerMarkdownPreview)
  store.target.appendChild(retryButton)
}

const triggerAjaxMarkdownPreview = async () => {
  try {
    const response = await window.fetch(store.endpoint, {
      method: 'POST',
      mode: 'same-origin',
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': store.csrfToken
      },
      redirect: 'follow',
      referrerPolicy: 'same-origin',
      body: JSON.stringify({
        guidance_markdown: store.source.value,
        authenticity_token: store.authenticityToken
      })
    })

    // insert the preview into the DOM
    const json = await response.json()
    store.target.innerHTML = json.preview_html
    addNotification('Preview updated.')
  } catch {
    setFailureStatus()
    addNotification(store.failureText)
  }
}

const manuallyTriggerMarkdownPreview = event => {
  event?.preventDefault()

  triggerAjaxMarkdownPreview()
}

const addEventListeners = (trigger, callback) => {
  trigger.addEventListener('click', callback)
}

// debounce the AJAX request so we don't hammer the server with one request per keystroke
const debouncedAjaxMarkdownPreview = debounce(() => {
  triggerAjaxMarkdownPreview()
}, 1000)

const inputEventListener = () => {
  setLoadingStatus()
  return debouncedAjaxMarkdownPreview()
}

const addLiveRegion = () => {
  const liveRegion = document.createElement('div')
  liveRegion.setAttribute('role', 'status')
  liveRegion.classList.add('app-markdown-editor__notification-area')
  store.liveRegion = liveRegion
  store.source.after(liveRegion)
}

const addNotification = text => {
  store.liveRegion.setAttribute('aria-busy', 'false')
  store.liveRegion.innerHTML = text
  setTimeout(() => {
    store.liveRegion.innerHTML = ''
  }, 5000)
}

/**
 * Submits markdown held in the source element to the endpoint when the source changes, and replaces the target element's content with the result of the request.
 * @param {HTMLElement} target - The element where the markdown preview should be rendered.
 * @param {HTMLElement} source - The element which contains the raw markdown for conversion.
 * @param {string} endpoint - The URL for the endpoint that renders the markdown.
 * @param {string} failureText - The text that should be displayed if the AJAX request returns an error
 * @param {string} loadingText - The text that should be displayed while waiting for the AJAX request to return
 */
const ajaxMarkdownPreview = (
  target,
  source,
  endpoint,
  failureText,
  loadingText
) => {
  store.target = target
  store.source = source
  store.endpoint = endpoint
  store.failureText = failureText
  store.loadingText = loadingText
  store.authenticityToken = document.querySelector(
    'input[name="authenticity_token"]'
  )?.value
  store.csrfToken = document
    .querySelector('meta[name="csrf-token"]')
    ?.getAttribute('content')
  addLiveRegion()

  // run on page load
  setLoadingStatus()
  triggerAjaxMarkdownPreview()

  // run when the user types
  source.addEventListener('input', inputEventListener)
}

export default ajaxMarkdownPreview
