set shell := ["zsh", "-cu"]

project := "AnyTime.xcodeproj"
scheme := "AnyTime"
package_path := "Packages/AnyTimeCore"
default_destination := "generic/platform=iOS Simulator"

default:
    @just --list

generate:
    command -v xcodegen >/dev/null || { echo "xcodegen is not installed"; exit 1; }
    xcodegen generate

open: generate
    open {{project}}

lint:
    command -v swiftlint >/dev/null || { echo "swiftlint is not installed"; exit 1; }
    swiftlint --config .swiftlint.yml

lint-fix:
    command -v swiftlint >/dev/null || { echo "swiftlint is not installed"; exit 1; }
    swiftlint --fix --config .swiftlint.yml

test:
    swift test --package-path {{package_path}}

build destination=default_destination:
    xcodebuild -scheme {{scheme}} -project {{project}} -destination '{{destination}}' build

verify destination=default_destination:
    command -v xcodegen >/dev/null || { echo "xcodegen is not installed"; exit 1; }
    command -v swiftlint >/dev/null || { echo "swiftlint is not installed"; exit 1; }
    xcodegen generate
    swiftlint --config .swiftlint.yml
    swift test --package-path {{package_path}}
    xcodebuild -scheme {{scheme}} -project {{project}} -destination '{{destination}}' build
