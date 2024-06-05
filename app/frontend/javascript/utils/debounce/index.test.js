import debounce from '.'

// Tell Vitest to mock all timeout functions
vi.useFakeTimers()

describe('debounce', () => {
  let functionToDebounce
  let debouncedFunc

  beforeEach(() => {
    functionToDebounce = vi.fn()
    debouncedFunc = debounce(functionToDebounce, 1000)
  })

  test('when called once the function executes once', () => {
    debouncedFunc()

    // Fast-forward time
    vi.runAllTimers()

    expect(functionToDebounce).toBeCalledTimes(1)
  })

  test('when called multiple times the function only executes once', () => {
    ;[...Array(100)].forEach(() => {
      debouncedFunc()
    })

    // Fast-forward time
    vi.runAllTimers()

    expect(functionToDebounce).toBeCalledTimes(1)
  })
})
