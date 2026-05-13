const size = 256
let index = size
let buffer: string

function getRandomBytes(byteLength: number): Uint8Array {
  // Prefer Web Crypto if available (browsers, some runtimes)
  if (typeof crypto !== 'undefined' && 'getRandomValues' in crypto) {
    const array = new Uint8Array(byteLength)
    crypto.getRandomValues(array)
    return array
  }

  // Fallback to Node.js crypto if available
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const nodeCrypto = require('crypto') as typeof import('crypto')
    return nodeCrypto.randomBytes(byteLength)
  } catch {
    // As a last resort, throw instead of silently falling back to Math.random()
    throw new Error('Secure random number generator is not available.')
  }
}

export function uid(length = 11) {
  if (!buffer || index + length > size * 2) {
    buffer = ''
    index = 0

    const bytes = getRandomBytes(size)
    for (let i = 0; i < bytes.length; i++) {
      const hex = bytes[i].toString(16).padStart(2, '0')
      buffer += hex
    }
  }
  return buffer.substring(index, (index += length))
}
