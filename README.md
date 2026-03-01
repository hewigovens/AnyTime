# AnyTime

AnyTime is now a SwiftUI rewrite of the original timezone-conversion app.

## What changed

- SwiftUI app lifecycle instead of legacy UIKit controllers
- Local Swift package (`Packages/AnyTimeCore`) for timezone catalog, persistence, search, and calculator state
- No CocoaPods runtime dependencies
- Xcode project generated from `project.yml` with XcodeGen
- Modern UX: searchable add sheet, swipe actions, drag reorder, quick `+/- 1h` and `+/- 1d` calculator controls

## Project layout

- `App/`: SwiftUI app and views
- `App/Resources/`: asset catalog and launch screen resources
- `Packages/AnyTimeCore/`: shared app logic and tests
- `project.yml`: declarative XcodeGen project spec

## Common commands

```bash
just generate
just lint
just test
just build
just verify
```

`just lint` and `just verify` expect `swiftlint` to be installed locally.

`just build` and `just verify` default to `generic/platform=iOS Simulator`. Pass a custom destination when needed:

```bash
just build "platform=iOS Simulator,name=iPhone 16"
```

## CI

GitHub Actions builds the app on every push and pull request by:

- installing `xcodegen`
- generating `AnyTime.xcodeproj` from `project.yml`
- running `swift test --package-path Packages/AnyTimeCore`
- building the `AnyTime` scheme for `generic/platform=iOS Simulator`
