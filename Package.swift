import PackageDescription

let package = Package(
    name: "TasksServer",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/typelift/Swiftz", versions: Version(0,6,0)..<Version(1,0,0))
    ]
)
