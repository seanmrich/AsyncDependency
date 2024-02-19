import Dependencies
import DataClient
import XCTest

final class DataClientTests: XCTestCase {
  @Dependency(\.data) var data
  
  func testAsync() async throws {
    try await withDependencies {
      $0.data = .liveValue
    } operation: {
      let model = try await data.createModel()
      print(model.created)
    }
  }
}
