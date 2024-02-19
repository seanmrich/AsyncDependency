import ComposableArchitecture
import Dependencies
import Foundation
import GRDB

@DependencyClient
public struct DataClient: Sendable {
  public var createModel: @Sendable () async throws -> Model
}

extension DependencyValues {
  public var data: DataClient {
    get { self[DataClient.self] }
    set { self[DataClient.self] = newValue }
  }
}

extension DataClient: TestDependencyKey {
  public static let testValue = DataClient()
}

extension DataClient: DependencyKey {
  public static let liveValue: DataClient = {
    let _db = AsyncActorBox<AppDatabase>()
    
    @Sendable
    func getDb() async throws -> AppDatabase {
      try await _db.wrapped(default: await AppDatabase())
    }
    
    return DataClient(
      createModel: { try await getDb().createModel() }
    )
  }()
}
