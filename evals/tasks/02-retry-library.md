# ABOUTME: Eval task definition for a retry utility library.
# ABOUTME: Tests algorithm choices, API design decisions, and composability.

# Task: Retry Utility Library

## The Prompt

Build a retry utility library in TypeScript. It should:
- Let callers retry failed async operations with configurable backoff
- Support different retry strategies
- Know when to stop retrying (max attempts, timeout, specific errors)
- Be usable as both a wrapper function and a decorator

That's it. Keep it simple. Make your own decisions on architecture.

## Why This Task

This task has genuine architectural slots:
- **Algorithm**: Exponential backoff vs linear vs fibonacci vs custom schedule
- **API design**: Function wrapper vs decorator vs class-based builder pattern
- **Error classification**: Retry all errors vs allowlist vs denylist vs custom predicate
- **Circuit breaker**: Include one or not? If so, how does it interact with retry?
- **Observability**: Callbacks vs events vs return metadata vs silent

These choices reflect different philosophies: minimal vs batteries-included, simple vs flexible.

## Acceptance Criteria

The output must be:
1. A working TypeScript library with types
2. Tests that pass covering retry behavior, backoff timing, and error classification
3. A developer can import it and use it in under 2 minutes

## Evaluation Dimensions

| Dimension | What to look for |
|-----------|-----------------|
| **Functionality** | Does retry actually work? Backoff timing correct? |
| **API design** | Is the API intuitive? Can you use it without reading all the docs? |
| **Approach creativity** | Did the process surface non-obvious design patterns? |
| **Composability** | Does it play well with existing code? Easy to integrate? |
| **Code quality** | Clean types, readable implementation, good test coverage? |
| **Edge cases** | Timeout during retry, concurrent retries, error during backoff? |
