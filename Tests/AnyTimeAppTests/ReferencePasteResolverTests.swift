import XCTest
@testable import AnyTime

@MainActor
final class ReferencePasteResolverTests: XCTestCase {
    func testPasteEasternTimePrefersNewYorkLabelAndZone() async throws {
        let result = await ReferencePasteResolver.resolve(
            from: "Wednesday, March 4, 2026, starting at 9:00 a.m. ET"
        )

        switch result {
        case let .success(resolution):
            XCTAssertEqual(resolution.timeZoneID, "America/New_York")
            XCTAssertEqual(resolution.preferredCityName, "New York")
            XCTAssertTrue(resolution.message.contains("in New York."))
            XCTAssertFalse(resolution.message.contains("Atikokan"))

            let calendar = Calendar(identifier: .gregorian)
            let resolvedDate = try XCTUnwrap(resolution.date)
            let components = calendar.dateComponents(
                in: TimeZone(identifier: "America/New_York")!,
                from: resolvedDate
            )

            XCTAssertEqual(components.year, 2026)
            XCTAssertEqual(components.month, 3)
            XCTAssertEqual(components.day, 4)
            XCTAssertEqual(components.hour, 9)
            XCTAssertEqual(components.minute, 0)

        case let .failure(message):
            XCTFail("Expected paste resolution to succeed, got failure: \(message)")
        }
    }

    func testPasteJapanTimePrefersTokyoLabelAndZone() async throws {
        let result = await ReferencePasteResolver.resolve(
            from: "Thursday, March 5, 2026 at 10:30 JST"
        )

        switch result {
        case let .success(resolution):
            XCTAssertEqual(resolution.timeZoneID, "Asia/Tokyo")
            XCTAssertEqual(resolution.preferredCityName, "Tokyo")
            XCTAssertTrue(resolution.message.contains("in Tokyo."))

            let calendar = Calendar(identifier: .gregorian)
            let resolvedDate = try XCTUnwrap(resolution.date)
            let components = calendar.dateComponents(
                in: TimeZone(identifier: "Asia/Tokyo")!,
                from: resolvedDate
            )

            XCTAssertEqual(components.year, 2026)
            XCTAssertEqual(components.month, 3)
            XCTAssertEqual(components.day, 5)
            XCTAssertEqual(components.hour, 10)
            XCTAssertEqual(components.minute, 30)

        case let .failure(message):
            XCTFail("Expected paste resolution to succeed, got failure: \(message)")
        }
    }
}
