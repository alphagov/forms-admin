import debounce from '.'

// Tell Jest to mock all timeout functions
jest.useFakeTimers()

describe('debounce', () => {
  let functionToDebounce
  let debouncedFunc

  beforeEach(() => {
    functionToDebounce = jest.fn()
    debouncedFunc = debounce(functionToDebounce, 1000)
  })

  test('when called once the function executes once', () => {
    debouncedFunc()

    // Fast-forward time
    jest.runAllTimers()

    expect(functionToDebounce).toBeCalledTimes(1)
  })

  test('when called multiple times the function only executes once', () => {
    ;[...Array(100)].forEach(() => {
      debouncedFunc()
    })

    // Fast-forward time
    jest.runAllTimers()

    expect(functionToDebounce).toBeCalledTimes(1)
  })
})
