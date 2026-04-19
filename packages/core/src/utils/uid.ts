function getRandomBytes(byteLength: number): Uint8Array {
  // Prefer Node.js crypto.randomBytes if available
  if (
    typeof globalThis !== 'undefined' &&
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).crypto?.getRandomValues === undefined
  ) {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires, @typescript-eslint/no-require-imports
      const nodeCrypto = require('crypto') as typeof import('crypto')
      return nodeCrypto.randomBytes(byteLength)
    } catch {
      // fall through to Web Crypto detection below
    }
  }

  // Use Web Crypto API if available (browser / modern runtimes)
  if (
    typeof globalThis !== 'undefined' &&
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).crypto?.getRandomValues
  ) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const webCrypto = (globalThis as any).crypto
    const array = new Uint8Array(byteLength)
    webCrypto.getRandomValues(array)
    return array
  }

  // If no cryptographically secure RNG is available, fail fast
  throw new Error('No cryptographically secure random number generator available')
}

export function uid(length = 11) {
  const byteLength = Math.ceil(length / 2)
  const bytes = getRandomBytes(byteLength)

  let hex = ''
  for (let i = 0; i < bytes.length; i++) {
    const byte = bytes[i]
    hex += byte.toString(16).padStart(2, '0')
  }

  return hex.slice(0, length)
}
