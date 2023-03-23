/**
 * Creates a GOV.UK secondary button with arbitrary text
 * @param {string} text - The text that will be displayed on the button.
 */
const createButton = text => {
  const button = document.createElement('button')
  button.innerHTML = text
  button.className = 'govuk-button govuk-button--secondary'
  button.dataset.module = 'govuk-button'
  return button
}

/**
 * Adds a copy button to an element.
 * @param {HTMLElement} element - The root element in which the copy button will be appended.
 * @param {HTMLElement} copyTarget - The element whose text will be copied to the clipboard.
 * @param {string} buttonText - The text that will be displayed on the copy button.
 */
const copyToClipboard = (element, copyTarget, buttonText) => {
  if (navigator?.clipboard?.writeText) {
    const button = createButton(buttonText)
    try {
      button.addEventListener('click', () => {
        navigator.clipboard.writeText(copyTarget.textContent.trim())
      })
      element.appendChild(button)
    } catch {
      button.remove()
    }
  }
}

export default copyToClipboard
