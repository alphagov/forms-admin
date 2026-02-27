import debounce from '../utils/debounce'

class AjaxMarkdownPreview {
  constructor (target, source, endpoint, i18n) {
    this.target = target
    this.source = source
    this.endpoint = endpoint
    this.i18n = i18n
    this.liveRegion = null
    this.errorArea = null
    this.authenticityToken = document.querySelector(
      'input[name="authenticity_token"]'
    )?.value
    this.csrfToken = document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute('content')

    // Create a debounced version of triggerAjaxMarkdownPreview bound to this instance
    this.debouncedAjaxMarkdownPreview = debounce(() => {
      this.triggerAjaxMarkdownPreview()
    }, 1000)

    this.init()
  }

  init () {
    this.addLiveRegion()
    this.createErrorArea()

    // run on page load
    this.setLoadingStatus()
    this.triggerAjaxMarkdownPreview()

    // run when the user types
    this.source.addEventListener('input', () => this.inputEventListener())
  }

  setLoadingStatus () {
    this.liveRegion.setAttribute('aria-busy', 'true')
    this.target.innerHTML = `<p>${this.i18n.preview_loading}</p>`
  }

  setFailureStatus () {
    this.target.innerHTML = `<p>${this.i18n.preview_error}</p>`
    const retryButton = document.createElement('button')
    retryButton.classList.add('govuk-button', 'govuk-button--secondary')
    retryButton.innerHTML = 'Retry preview'
    retryButton.addEventListener('click', event => {
      this.manuallyTriggerMarkdownPreview(event)
    })
    this.target.appendChild(retryButton)
  }

  async triggerAjaxMarkdownPreview () {
    try {
      if (this.endpoint) {
        const response = await window.fetch(this.endpoint, {
          method: 'POST',
          mode: 'same-origin',
          cache: 'no-cache',
          credentials: 'same-origin',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.csrfToken
          },
          redirect: 'follow',
          referrerPolicy: 'same-origin',
          body: JSON.stringify({
            markdown: this.source.value,
            authenticity_token: this.authenticityToken
          })
        })

        // insert the preview into the DOM
        const json = await response.json()
        this.target.innerHTML = json.preview_html
        if (json.errors.length > 0) {
          this.addErrorToField(json.errors[0])
          this.addErrorClass()
        } else {
          this.clearErrorsFromField()
          this.removeErrorClass()
        }
        this.addNotification('Preview updated.')
      } else {
        throw new Error('No endpoint set')
      }
    } catch {
      this.setFailureStatus()
      this.addNotification(this.i18n.preview_error)
    }
  }

  manuallyTriggerMarkdownPreview (event) {
    event?.preventDefault()
    this.triggerAjaxMarkdownPreview()
  }

  inputEventListener () {
    this.setLoadingStatus()
    return this.debouncedAjaxMarkdownPreview()
  }

  addLiveRegion () {
    const liveRegion = document.createElement('div')
    liveRegion.setAttribute('role', 'status')
    liveRegion.classList.add('app-markdown-editor__notification-area')
    this.liveRegion = liveRegion
    this.source.after(liveRegion)
  }

  addNotification (text) {
    this.liveRegion.setAttribute('aria-busy', 'false')
    this.liveRegion.innerHTML = text
    setTimeout(() => {
      this.liveRegion.innerHTML = ''
    }, 5000)
  }

  createErrorArea () {
    // Use existing error area if there's a server side error present on the field
    this.errorArea =
      this.source
        .closest('.govuk-form-group')
        ?.querySelector('.govuk-error-message') ?? document.createElement('p')
    this.errorArea.classList.add(
      'govuk-error-message',
      'app-markdown-editor__error-message'
    )
    this.source.closest('.govuk-form-group').prepend(this.errorArea)
    this.setAriaAttributesForError()
  }

  setAriaAttributesForError () {
    if (!this.errorArea.getAttribute('id')) {
      const id = `${this.source.getAttribute('id')}-error`
      this.errorArea.setAttribute('id', id)
      this.source.setAttribute(
        'aria-describedby',
        `${id} ${this.source.getAttribute('aria-describedby')}`
      )
    }
    this.errorArea.setAttribute('aria-live', 'polite')
  }

  addErrorToField (error) {
    if (!this.errorArea) this.createErrorArea()
    this.errorArea.innerHTML = `<span class="govuk-visually-hidden">Error:</span> ${error}`
  }

  clearErrorsFromField () {
    if (!this.errorArea) this.createErrorArea()
    this.errorArea.innerHTML = ''
  }

  addErrorClass () {
    this.source
      .closest('.govuk-form-group')
      ?.classList.add('govuk-form-group--error')
    this.source.classList.add('govuk-textarea--error')
  }

  removeErrorClass () {
    this.source
      .closest('.govuk-form-group--error')
      ?.classList.remove('govuk-form-group--error')
    this.source.classList.remove('govuk-textarea--error')
  }
}

/**
 * Submits markdown held in the source element to the endpoint when the source changes, and replaces the target element's content with the result of the request.
 * @param {HTMLElement} target - The element where the markdown preview should be rendered.
 * @param {HTMLElement} source - The element which contains the raw markdown for conversion.
 * @param {string} endpoint - The URL for the endpoint that renders the markdown.
 * @param {Object} i18n - An object containing translations for the component.
 * @returns {AjaxMarkdownPreview} The instance of the AjaxMarkdownPreview class.
 */
const ajaxMarkdownPreview = (target, source, endpoint, i18n) => {
  return new AjaxMarkdownPreview(target, source, endpoint, i18n)
}

export default ajaxMarkdownPreview
export { AjaxMarkdownPreview }
