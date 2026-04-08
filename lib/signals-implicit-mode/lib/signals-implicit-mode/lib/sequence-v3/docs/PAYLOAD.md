# Sequence Payload System Documentation

This document provides a comprehensive overview of how the Sequence wallet contracts encode, decode, and execute payloads. It explains the payload structure, encoding schemes, execution flow, and how payloads integrate with the broader signature and configuration systems.

---

## **1. Overview**

The Sequence payload system is the core mechanism through which wallets execute batched operations. Payloads are encoded data structures that contain:

- **Transaction calls** with target addresses, values, and calldata
- **Configuration updates** for wallet parameters
- **Message validations** for arbitrary data signing
- **Digest verifications** for ERC-1271 compatibility

Payloads are designed to be:

1. **Gas-efficient** through compact binary encoding
2. **Flexible** to support various operation types
3. **Secure** through EIP-712 structured hashing
4. **Batchable** to execute multiple operations atomically

---

## **2. Payload Types**

The system supports four distinct payload kinds, each serving different purposes:

### **2.1 Transaction Payloads (`KIND_TRANSACTIONS = 0x00`)**

Transaction payloads contain batched calls to external contracts or self-execution logic. These are the most common payload type and support:

- Multiple contract calls in sequence
- Value transfers with calls
- Delegate calls for extension execution
- Gas limit specifications
- Error handling behaviors
- Fallback-only execution modes

### **2.2 Message Payloads (`KIND_MESSAGE = 0x01`)**

Message payloads allow wallets to sign arbitrary data for off-chain verification. This is useful for:

- Meta-transactions
- Off-chain authorization
- Cross-chain message signing
- General-purpose data signing

### **2.3 Configuration Update Payloads (`KIND_CONFIG_UPDATE = 0x02`)**

Configuration update payloads enable wallet reconfiguration through:

- Signer set modifications
- Threshold adjustments
- Extension enablement/disablement
- Checkpoint updates

### **2.4 Digest Payloads (`KIND_DIGEST = 0x03`)**

Digest payloads provide ERC-1271 compatibility by allowing wallets to validate pre-computed message hashes.

---

## **3. Payload Structure**

### **3.1 Core Payload Structure**

All payloads share a common structure defined by the `Decoded` struct:

```solidity
struct Decoded {
    uint8 kind;           // Payload type identifier
    bool noChainId;       // Chain ID inclusion flag
    // Transaction-specific fields
    Call[] calls;         // Array of call operations
    uint256 space;        // Nonce space identifier
    uint256 nonce;        // Nonce value for replay protection
    // Message-specific fields
    bytes message;        // Raw message data
    // Configuration-specific fields
    bytes32 imageHash;    // New configuration hash
    // Digest-specific fields
    bytes32 digest;       // Pre-computed message hash
    // Common fields
    address[] parentWallets; // Parent wallet addresses
}
```

### **3.2 Call Structure**

Individual calls within transaction payloads are defined by the `Call` struct:

```solidity
struct Call {
    address to;                    // Target contract address
    uint256 value;                 // ETH value to send
    bytes data;                    // Calldata for the call
    uint256 gasLimit;              // Gas limit for execution
    bool delegateCall;             // Delegate call flag
    bool onlyFallback;             // Fallback-only execution
    uint256 behaviorOnError;       // Error handling strategy
}
```

---

## **4. Payload Encoding**

### **4.1 Transaction Payload Encoding**

Transaction payloads use a compact binary encoding scheme optimized for gas efficiency. The encoding follows this structure:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Global Flag (1 byte)                                                        │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ Bit 0: Space flag (0 = read space, 1 = space is 0)                      │ │
│ │ Bits 1-3: Nonce size (0-7 bytes)                                        │ │
│ │ Bit 4: Single call flag (0 = multiple calls, 1 = single call)           │ │
│ │ Bit 5: Call count size (0 = 1 byte, 1 = 2 bytes)                        │ │
│ │ Bits 6-7: Reserved                                                      │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────┤
│ Space (0 or 20 bytes) - only if space flag is 0                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ Nonce (0-7 bytes) - size determined by bits 1-3                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ Call Count (1-2 bytes) - size determined by bit 5                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ Call Array (call count length)                                              │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ Call Flags (1 byte)                                                     │ │
│ │ ┌─────────────────────────────────────────────────────────────────────┐ │ │
│ │ │ Bit 0: Self-call flag (0 = external, 1 = self)                      │ │ │
│ │ │ Bit 1: Value flag (0 = no value, 1 = has value)                     │ │ │
│ │ │ Bit 2: Data flag (0 = no data, 1 = has data)                        │ │ │
│ │ │ Bit 3: Gas limit flag (0 = no limit, 1 = has limit)                 │ │ │
│ │ │ Bit 4: Delegate call flag                                           │ │ │
│ │ │ Bit 5: Fallback-only flag                                           │ │ │
│ │ │ Bits 6-7: Behavior on error (00=ignore, 01=revert, 10=abort)        │ │ │
│ │ └─────────────────────────────────────────────────────────────────────┘ │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Target Address (0 or 20 bytes) - only if not self-call                  │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Value (0 or 32 bytes) - only if value flag is set                       │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Data Size (0 or 3 bytes) - only if data flag is set                     │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Data (0 or N bytes) - only if data flag is set                          │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Gas Limit (0 or 32 bytes) - only if gas limit flag is set               │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### **4.2 Global Flag Breakdown**

The global flag byte controls the overall payload structure:

```
Global Flag: [7][6][5][4][3][2][1][0]
             │  │  │  │  │  │  │  └── [0] Space flag
             │  │  │  │  │  │  └───── [1][0] Nonce size
             │  │  │  │  │  └──────── [2][1] Nonce size
             │  │  │  │  └─────────── [3][2] Nonce size
             │  │  │  └────────────── [4] Single call flag
             │  │  └───────────────── [5] Call count size
             │  └──────────────────── [6] Reserved
             └─────────────────────── [7] Reserved
```

**Space Flag (Bit 0):**

- `0`: Read 20-byte space address from payload
- `1`: Set space to 0 (default space)

**Nonce Size (Bits 1-3):**

- `000`: No nonce (nonce = 0)
- `001`: 1-byte nonce
- `010`: 2-byte nonce
- `011`: 3-byte nonce
- `100`: 4-byte nonce
- `101`: 5-byte nonce
- `110`: 6-byte nonce
- `111`: 7-byte nonce

**Single Call Flag (Bit 4):**

- `0`: Multiple calls (read call count)
- `1`: Single call (call count = 1)

**Call Count Size (Bit 5):**

- `0`: Call count stored in 1 byte
- `1`: Call count stored in 2 bytes

### **4.3 Call Flags Breakdown**

Each call begins with a flags byte that controls its execution parameters:

```
Call Flags: [7][6][5][4][3][2][1][0]
            │  │  │  │  │  │  │  └─── [0] Self-call flag
            │  │  │  │  │  │  └────── [1] Value flag
            │  │  │  │  │  └───────── [2] Data flag
            │  │  │  │  └──────────── [3] Gas limit flag
            │  │  │  └─────────────── [4] Delegate call flag
            │  │  └────────────────── [5] Fallback-only flag
            │  └───────────────────── [6][0] Behavior on error
            └──────────────────────── [7][1] Behavior on error
```

**Self-call Flag (Bit 0):**

- `0`: External call (read target address)
- `1`: Self-call (target = address(this))

**Value Flag (Bit 1):**

- `0`: No ETH value
- `1`: Read 32-byte value from payload

**Data Flag (Bit 2):**

- `0`: No calldata
- `1`: Read 3-byte data size + N bytes of data

**Gas Limit Flag (Bit 3):**

- `0`: Use remaining gas
- `1`: Read 32-byte gas limit from payload

**Delegate Call Flag (Bit 4):**

- `0`: Regular call
- `1`: Delegate call

**Fallback-only Flag (Bit 5):**

- `0`: Execute normally
- `1`: Only execute if previous call failed

**Behavior on Error (Bits 6-7):**

- `00`: Ignore error, continue execution
- `01`: Revert entire transaction
- `10`: Abort execution, stop processing
- `11`: Reserved

---

## **5. Payload Execution**

### **5.1 Execution Flow**

The payload execution follows this sequence:

1. **Decode Payload**: Parse the binary payload into structured data
2. **Nonce Validation**: Consume the nonce to prevent replay attacks
3. **Signature Verification**: Validate the signature against the payload
4. **Call Execution**: Execute each call in sequence
5. **Error Handling**: Apply error handling based on call configuration

### **5.2 Call Execution Modes**

#### **Regular Calls**

Standard contract calls that execute with the specified parameters and return control to the wallet.

#### **Delegate Calls**

Execute code in the context of the wallet contract, allowing extensions to modify wallet state.

#### **Fallback-only Calls**

Only execute when the immediately preceding call fails (and has the `BEHAVIOR_IGNORE_ERROR` behavior), enabling conditional execution flows. See Error Handling Strategies below.

### **5.3 Error Handling Strategies**

The system provides three error handling behaviors:

1. **Ignore Error (`BEHAVIOR_IGNORE_ERROR`)**

   - Continue execution with subsequent calls
   - Set error flag for fallback-only calls
   - Emit `CallFailed` event

2. **Revert on Error (`BEHAVIOR_REVERT_ON_ERROR`)**

   - Revert entire transaction
   - Rollback all state changes
   - Emit `Reverted` error

3. **Abort on Error (`BEHAVIOR_ABORT_ON_ERROR`)**
   - Stop processing remaining calls
   - Keep successful call results
   - Emit `CallAborted` event

---

## **6. EIP-712 Integration**

### **6.1 Domain Separator**

Payloads use EIP-712 for structured hashing with the domain:

```
EIP712Domain(
    name: "Sequence Wallet"
    version: "3"
    chainId: block.chainid (or 0 if noChainId)
    verifyingContract: wallet address
)
```

### **6.2 Type Hashes**

Each payload type has a specific type hash:

- **Calls**: `keccak256("Calls(Call[] calls,uint256 space,uint256 nonce,address[] wallets)")`
- **Message**: `keccak256("Message(bytes message,address[] wallets)")`
- **ConfigUpdate**: `keccak256("ConfigUpdate(bytes32 imageHash,address[] wallets)")`

### **6.3 Call Hashing**

Individual calls are hashed using:

```
keccak256(
    CALL_TYPEHASH,
    to,
    value,
    keccak256(data),
    gasLimit,
    delegateCall,
    onlyFallback,
    behaviorOnError
)
```

---

## **7. Gas Optimization Features**

### **7.1 Compact Encoding**

The payload system uses several techniques to minimize gas costs:

- **Flag-based encoding**: Single bytes control multiple parameters
- **Variable-length fields**: Only encode necessary data
- **Self-call optimization**: Avoid 20-byte address encoding for self-calls
- **Conditional encoding**: Skip fields that have default values

### **7.2 Batch Processing**

Multiple calls can be executed in a single transaction, reducing:

- Transaction overhead
- Gas costs for multiple operations
- Network congestion
- User interaction requirements

---

## **8. Security Considerations**

### **8.1 Replay Protection**

- **Nonce system**: Each payload requires a unique nonce
- **Space isolation**: Different nonce spaces prevent cross-contamination
- **Chain ID binding**: Prevents cross-chain replay attacks

### **8.2 Access Control**

- **Signature validation**: All payloads require valid signatures
- **Configuration binding**: Payloads are tied to specific wallet configurations
- **Extension isolation**: Delegate calls are restricted to approved extensions

### **8.3 Error Handling**

- **Graceful degradation**: Failed calls don't necessarily fail the entire batch
- **Gas protection**: Individual gas limits prevent infinite loops
- **State consistency**: Error behaviors maintain wallet integrity

---

## **Conclusion**

The Sequence payload system provides a powerful, gas-efficient mechanism for executing complex wallet operations. Through its compact binary encoding, flexible call structures, and comprehensive error handling, it enables wallets to perform sophisticated multi-step operations while maintaining security and efficiency.

The system's integration with the broader Sequence ecosystem—including chained signatures, smart sessions, and configuration management—creates a cohesive framework for advanced wallet functionality. The payload system serves as the execution engine that brings together all these components into a unified user experience.

This documentation serves as a technical reference for developers implementing and extending the payload system, providing both high-level architectural understanding and detailed implementation guidance.
