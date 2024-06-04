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

const mockFetchWithServerError = (jsonResponse, delayTime) =>
  vi.fn().mockImplementation(() => {
    return Promise.reject(new Error('API is down'))
  })

export {
  fetchStub,
  delayedFetchStub,
  mockFetch,
  mockFetchWithDelay,
  mockFetchWithServerError
}
