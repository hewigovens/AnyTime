import Foundation

enum ClockMath {
    static func uniqueValidTimeZoneIDs(from identifiers: [String]) -> [String] {
        var seen = Set<String>()
        return identifiers.compactMap { identifier in
            guard TimeZone(identifier: identifier) != nil else {
                return nil
            }
            guard seen.insert(identifier).inserted else {
                return nil
            }
            return identifier
        }
    }

    static func utcOffsetText(seconds: Int) -> String {
        let sign = seconds >= 0 ? "+" : "-"
        let absoluteSeconds = abs(seconds)
        let hours = absoluteSeconds / 3_600
        let minutes = (absoluteSeconds % 3_600) / 60

        if minutes == 0 {
            return "UTC\(sign)\(hours)"
        }

        return "UTC\(sign)\(hours):\(String(format: "%02d", minutes))"
    }

    static func searchableUTCOffsetTerms(seconds: Int) -> [String] {
        let sign = seconds >= 0 ? "+" : "-"
        let absoluteSeconds = abs(seconds)
        let hours = absoluteSeconds / 3_600
        let minutes = (absoluteSeconds % 3_600) / 60
        let colonMinutes = String(format: "%02d", minutes)
        let compactMinutes = String(format: "%02d", minutes)
        let compactHours = String(format: "%02d", hours)

        var terms = [
            utcOffsetText(seconds: seconds),
            "GMT\(sign)\(hours)",
            "GMT\(sign)\(compactHours)\(compactMinutes)",
            "UTC\(sign)\(compactHours)\(compactMinutes)",
            "\(sign)\(hours)",
            "\(sign)\(compactHours)\(compactMinutes)"
        ]

        if minutes > 0 {
            terms.append("GMT\(sign)\(hours):\(colonMinutes)")
            terms.append("UTC\(sign)\(hours):\(colonMinutes)")
        }

        return Array(Set(terms))
    }

    static func comparisonText(targetSeconds: Int, referenceSeconds: Int) -> String {
        let delta = targetSeconds - referenceSeconds
        guard delta != 0 else {
            return "Same time as reference"
        }

        let absoluteSeconds = abs(delta)
        let hours = absoluteSeconds / 3_600
        let minutes = (absoluteSeconds % 3_600) / 60
        var pieces = [String]()

        if hours > 0 {
            pieces.append("\(hours)h")
        }
        if minutes > 0 {
            pieces.append("\(minutes)m")
        }

        let direction = delta > 0 ? "ahead" : "behind"
        return "\(pieces.joined(separator: " ")) \(direction)"
    }

    static func dayText(
        for date: Date,
        targetTimeZone: TimeZone,
        referenceTimeZone: TimeZone
    ) -> String? {
        let targetDate = Calendar.gregorianLocalDate(for: date, in: targetTimeZone)
        let referenceDate = Calendar.gregorianLocalDate(for: date, in: referenceTimeZone)
        let dayDelta = Calendar.utcGregorian.dateComponents([.day], from: referenceDate, to: targetDate).day ?? 0

        switch dayDelta {
        case ..<(-1):
            return "\(abs(dayDelta)) days earlier"
        case -1:
            return "Yesterday"
        case 1:
            return "Tomorrow"
        case 2...:
            return "\(dayDelta) days later"
        default:
            return nil
        }
    }
}

private extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
    static let utcGregorian: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    static func gregorianLocalDate(for date: Date, in timeZone: TimeZone) -> Date {
        var calendar = gregorian
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return utcGregorian.date(from: components) ?? date
    }
}
