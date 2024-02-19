import Dependencies
import Foundation
import GRDB

public struct Model: Codable, Sendable {
  public var id: Int64?
  public var created: Date
  
  public init(id: Int64? = nil, created: Date? = nil) {
    self.id = id
    self.created = created ?? {
      @Dependency(\.date.now) var now
      return now
    }()
  }
}

extension Model: FetchableRecord, MutablePersistableRecord {
  public mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
