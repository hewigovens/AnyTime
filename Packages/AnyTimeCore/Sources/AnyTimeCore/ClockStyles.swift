import Foundation

public enum ClockLabelStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case city
    case abbreviation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .city:
            "City"
        case .abbreviation:
            "Abbreviation"
        }
    }
}

public enum ClockDateStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case timeOnly
    case weekdayAndTime
    case dateAndTime

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .timeOnly:
            "Time only"
        case .weekdayAndTime:
            "Weekday + time"
        case .dateAndTime:
            "Date + time"
        }
    }

    public func formatted(
        date: Date,
        in timeZone: TimeZone,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone

        switch self {
        case .timeOnly:
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        case .weekdayAndTime:
            formatter.setLocalizedDateFormatFromTemplate("EEEjm")
        case .dateAndTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }

        return formatter.string(from: date)
    }
}
