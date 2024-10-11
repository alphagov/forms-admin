/**
 * @vitest-environment jsdom
 */

import copyToClipboard from '../copy-to-clipboard'

Object.defineProperty(navigator, 'clipboard', {
  value: {
    writeText: () => {}
  }
})

describe('Copy to clipboard', () => {
  document.body.innerHTML = `
    <div data-module="copy-to-clipboard" data-copy-button-text="Copy to clipboard">
      <p data-copy-target>It worked!</p>
    </div>
  `

  document
    .querySelectorAll('[data-module="copy-to-clipboard"]')
    .forEach(element => {
      copyToClipboard(
        element,
        element.querySelector('[data-copy-target]'),
        element.dataset.copyButtonText
      )
    })

  const copyButton = document.querySelector('button')

  test('button is created', () => {
    expect(copyButton.innerHTML).toBe('Copy to clipboard')
  })

  test('text is written to clipboard', () => {
    vi.spyOn(navigator.clipboard, 'writeText')
    copyButton.click()

    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('It worked!')
  })

  test('the click event calls event.preventDefault', () => {
    const event = new window.Event('click')
    event.preventDefault = vi.fn()
    document.querySelector('button').dispatchEvent(event)

    expect(event.preventDefault).toHaveBeenCalled()
  })
})
