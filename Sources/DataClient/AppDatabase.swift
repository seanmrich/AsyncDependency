import GRDB

actor AppDatabase {
  let dbQueue: DatabaseQueue
  
  init() async throws {
    self.dbQueue = try DatabaseQueue(path: ":memory:")
    try migrate()
  }
}

extension AppDatabase {
  /// - Important: Any changes to the scheme must by synchronized with the one defined in `NamesDatabaseBuilder`.
  /// Otherwise the database files generated in that app won't be compatible with this app.
  fileprivate func migrate() throws {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("v1") { db in
      try db.create(table: "model") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("created", .date).notNull()
      }
    }
    try migrator.migrate(dbQueue)
  }
  
  func createModel() async throws -> Model {
    try await dbQueue.write { db in
      try Model().inserted(db)
    }
  }
}
