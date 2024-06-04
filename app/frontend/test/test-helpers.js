const fetchStub = jsonResponse => {
  return {
    ok: () => Promise.resolve(true),
    json: () => Promise.resolve(jsonResponse)
  }
}

const delayedFetchStub = (jsonResponse, delayTime) => {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve(fetchStub(jsonResponse))
    }, delayTime)
  })
}

const mockFetch = jsonResponse =>
  vi.fn().mockImplementation(() => fetchStub(jsonResponse))

const mockFetchWithDelay = (jsonResponse, delayTime) =>
  vi.fn().mockImplementation(() => delayedFetchStub(jsonResponse, delayTime))

// vitest timers don't work nicely with promises
const flushPromises = async () => {
  const timers = await vi.importActual('timers')
  return timers.setImmediate
}

export {
  fetchStub,
  delayedFetchStub,
  mockFetch,
  mockFetchWithDelay,
  flushPromises
}
