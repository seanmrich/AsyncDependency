import Semaphore

/// An actor that wraps a mutable value with an asynchronous initializer
///
/// The value will only be generated once. Access to the wrapped value is synchronized. If `Value` doesn't need an asynchronous
/// initializer, use `ActorBox` instead.
///
/// Consider a dependency that uses a resource like a database that should only have a single connection.
/// ```
/// let liveValue: DatabaseClient = {
///   let _db = AsyncActorBox<Db>()
///   func getDb() async throws -> Db {
///     try await _db.wrapped(default: await Db(path: dbPath))
///   }
///
///   return DatabaseClient(
///     fetchRecords: { try await getDb().records() }
///   )
/// }()
/// ```
public actor AsyncActorBox<Value: Sendable> {
  private var wrapped: Value?
  private let semaphore = AsyncSemaphore(value: 1)
  
  public init() {}
}

// NOTE: All methods are potentially mutating, and there is a suspension point in the
//       `wrapped(default:)` method when fetching the `defaultValue`. It's possible that, while
//       in that suspension point, another thread could re-enter the `wrapped(default:)` method
//       or call the `set(_:)` and `reset()` methods. This could potentially allow `wrapped`
//       to be set more than once.
//       To prevent this issue, a semaphore is used to prevent re-entrancy for all mutating
//       methods.

public extension AsyncActorBox {
  func wrapped(
    default defaultValue: @Sendable @autoclosure () async throws -> Value
  ) async throws -> Value {
    // Handles actor reentrancy problem so the `defaultValue` is only executed once
    try await semaphore.waitUnlessCancelled()
    defer { semaphore.signal() }

    if let existing = wrapped {
      return existing
    }
    else {
      let new = try await defaultValue()
      wrapped = new
      return new
    }
  }
  
  func set(_ new: Value) async throws {
    try await semaphore.waitUnlessCancelled()
    defer { semaphore.signal() }

    wrapped = new
  }
  
  func reset() async throws {
    try await semaphore.waitUnlessCancelled()
    defer { semaphore.signal() }

    wrapped = nil
  }
}
