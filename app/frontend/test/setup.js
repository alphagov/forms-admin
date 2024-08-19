import { beforeEach, vi } from 'vitest'

beforeEach(() => {
  // in some cases the console.error is called immediately after the test is
  // run, so we have to do this here instead of an afterEach block
  vi.restoreAllMocks()

  // mock console.error and make it throw a real error in the test suite context
  vi.spyOn(console, 'error').mockImplementation(message => {
    throw new Error(
      `Failing due to test calling console.error with message: ${message}`
    )
  })
})
