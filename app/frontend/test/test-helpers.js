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
  jest.fn().mockImplementation(() => fetchStub(jsonResponse))

const mockFetchWithDelay = (jsonResponse, delayTime) =>
  jest.fn().mockImplementation(() => delayedFetchStub(jsonResponse, delayTime))

// jest timers don't work nicely with promises
const flushPromises = () =>
  new Promise(jest.requireActual('timers').setImmediate)

export {
  fetchStub,
  delayedFetchStub,
  mockFetch,
  mockFetchWithDelay,
  flushPromises
}
