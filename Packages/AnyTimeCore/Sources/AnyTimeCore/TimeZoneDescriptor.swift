import Foundation

public struct TimeZoneDescriptor: Identifiable, Hashable, Sendable {
    public let identifier: String
    public let continent: String
    public let region: String?
    public let city: String

    public var id: String { identifier }

    public var displayPath: String {
        ([continent] + regionParts).joined(separator: " / ")
    }

    public var locationLine: String {
        if displayPath.isEmpty || displayPath == city {
            return "World clock"
        }
        return displayPath
    }

    public var selectionTitle: String {
        if city == identifier {
            return identifier
        }
        return "\(city) (\(identifier))"
    }

    public var sectionTitle: String {
        if let region, region.isEmpty == false {
            return "\(continent) / \(region)"
        }
        return continent
    }

    public init?(identifier: String) {
        guard TimeZone(identifier: identifier) != nil else {
            return nil
        }

        self.identifier = identifier

        let parts = identifier
            .split(separator: "/")
            .map { String($0).replacingOccurrences(of: "_", with: " ") }

        switch parts.count {
        case 0:
            return nil
        case 1:
            continent = "Universal"
            region = nil
            city = parts[0]
        case 2:
            continent = parts[0]
            region = nil
            city = parts[1]
        default:
            continent = parts[0]
            region = parts[1 ..< parts.count - 1].joined(separator: " / ")
            city = parts[parts.count - 1]
        }
    }

    public func abbreviation(at date: Date) -> String {
        guard let timeZone = TimeZone(identifier: identifier) else {
            return identifier
        }
        return timeZone.abbreviation(for: date) ?? ClockMath.utcOffsetText(seconds: timeZone.secondsFromGMT(for: date))
    }

    var searchTerms: [String] {
        var terms = [
            identifier,
            identifier.replacingOccurrences(of: "/", with: " "),
            continent,
            region,
            city,
            displayPath,
            locationLine,
            selectionTitle
        ]
        terms.append(contentsOf: searchAliases)
        terms.append(contentsOf: offsetSearchTerms)
        terms.append(contentsOf: abbreviationSearchTerms)

        return Array(Set(terms.compactMap { value in
            guard let value, value.isEmpty == false else {
                return nil
            }
            return value
        }))
    }

    private var searchAliases: [String] {
        Self.searchAliasesByIdentifier[identifier, default: []]
    }

    private var abbreviationSearchTerms: [String] {
        guard let timeZone = TimeZone(identifier: identifier) else {
            return []
        }

        return Array(Set(Self.searchReferenceDates.compactMap { date in
            timeZone.abbreviation(for: date)
        }))
    }

    private var offsetSearchTerms: [String] {
        guard let timeZone = TimeZone(identifier: identifier) else {
            return []
        }

        let offsets = Set(Self.searchReferenceDates.map { timeZone.secondsFromGMT(for: $0) })
        return offsets.flatMap { seconds in
            ClockMath.searchableUTCOffsetTerms(seconds: seconds)
        }
    }

    private static let searchReferenceDates: [Date] = [
        ISO8601DateFormatter().date(from: "2026-01-15T12:00:00Z") ?? .distantPast,
        ISO8601DateFormatter().date(from: "2026-07-15T12:00:00Z") ?? .distantFuture,
        .now
    ]

    private static let searchAliasesByIdentifier: [String: [String]] = [
        "Africa/Johannesburg": ["Cape Town", "Pretoria"],
        "Asia/Kolkata": ["Delhi", "New Delhi", "Mumbai", "Bangalore"],
        "Asia/Seoul": ["South Korea"],
        "Asia/Shanghai": ["Beijing", "Shenzhen", "Guangzhou", "China Mainland"],
        "Asia/Tokyo": ["Japan"],
        "Europe/Kyiv": ["Kiev"],
        "Pacific/Auckland": ["Wellington"]
    ]

    private var regionParts: [String] {
        guard let region, region.isEmpty == false else {
            return []
        }

        return region
            .split(separator: "/")
            .map(String.init)
    }
}
