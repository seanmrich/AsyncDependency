// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "AsyncDependency",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "DataClient", targets: ["DataClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", exact: "6.23.0"),
    .package(url: "https://github.com/groue/Semaphore", exact: "0.0.8"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.8.0"),
  ],
  targets: [
    .target(
      name: "DataClient",
      dependencies: [
        .composableArchitecture,
        .dependencies,
        .grdb,
        .semaphore
      ]
    ),
    .testTarget(
      name: "DataClientTests",
      dependencies: [
        "DataClient"
      ]
    ),
  ]
)

extension Target.Dependency {
  static let composableArchitecture = Target.Dependency.product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
  )
  static let dependencies = Target.Dependency.product(
    name: "Dependencies",
    package: "swift-dependencies"
  )
  static let grdb = Target.Dependency.product(
    name: "GRDB",
    package: "GRDB.swift"
  )
  static let semaphore = Target.Dependency.product(
      name: "Semaphore",
      package: "Semaphore"
  )
}

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(
    .unsafeFlags([
      "-Xfrontend", "-warn-concurrency",
      "-Xfrontend", "-enable-actor-data-race-checks"
    ])
  )
}
