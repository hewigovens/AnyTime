# AnyTime

AnyTime is a modern SwiftUI rewrite of the original timezone calculator app.

It keeps the original "timezone calculator" idea, but the codebase is now built around SwiftUI, Swift Package Manager, XcodeGen, and a small local core package for search, persistence, and clock math.

## Highlights

- SwiftUI app lifecycle and views
- Local Swift package at `Packages/AnyTimeCore` for app logic and tests
- Search by city, region, abbreviation, and UTC offset
- Smart paste that can extract date and timezone hints from the clipboard
- Drag reordering, swipe actions, quick `+/-1h` and `+/-1d` controls
- Dark mode support
- Generated Xcode project via `project.yml`
- GitHub Actions CI for test + simulator build

## Requirements

- Xcode 26.x
- macOS with command line tools installed
- `xcodegen` to generate the local Xcode project
- `just` if you want the shortcut commands
- `swiftlint` only if you plan to run `just lint` or `just verify`

The app target deploys to iOS 17.0 and newer.

## Project layout

- `App/`
  SwiftUI app, screens, components, theming, clipboard parsing, and launch resources.
- `Packages/AnyTimeCore/`
  Core models, timezone catalog/search, persistence, presentation formatting, and tests.
- `Design/`
  App icon source concepts.
- `project.yml`
  XcodeGen project definition.
- `justfile`
  Common local commands.

## Getting started

Generate the local Xcode project:

```bash
just generate
```

Open it in Xcode:

```bash
just open
```

Or build from the command line:

```bash
just build
```

The generated `AnyTime.xcodeproj` is intentionally not committed. Recreate it from `project.yml` whenever needed.

## Common commands

```bash
just generate
just open
just test
just build
just lint
just lint-fix
just verify
```

Notes:

- `just build` defaults to `generic/platform=iOS Simulator`
- `just verify` runs project generation, SwiftLint, package tests, and an app build
- `just lint` and `just verify` require `swiftlint`

Build a specific simulator destination:

```bash
just build "platform=iOS Simulator,name=iPhone 16"
```

## CI

GitHub Actions runs on every push and pull request. The workflow:

- checks out the repo
- installs `xcodegen`
- generates `AnyTime.xcodeproj`
- runs `swift test --package-path Packages/AnyTimeCore`
- builds the `AnyTime` scheme for `generic/platform=iOS Simulator`

Workflow file:

- `.github/workflows/ci.yml`

## Notes on smart paste

The clipboard parser can resolve:

- dates and times from freeform text
- explicit timezone IDs such as `Asia/Tokyo`
- UTC/GMT offsets such as `UTC+9`
- city-style queries through the local search index
- additional city resolution through geocoding

On supported iOS 26 devices, the app can also use Apple's local Foundation Models APIs as a best-effort hinting layer.
