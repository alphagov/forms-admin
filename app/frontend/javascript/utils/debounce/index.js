const debounce = (functionToDebounce, waitTime) => {
  let timeout

  return function debouncedFunction (...args) {
    const later = () => {
      clearTimeout(timeout)
      functionToDebounce(...args)
    }

    clearTimeout(timeout)
    timeout = setTimeout(later, waitTime)
  }
}

export default debounce
