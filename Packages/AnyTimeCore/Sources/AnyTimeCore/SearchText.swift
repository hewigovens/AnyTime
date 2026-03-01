import Foundation

extension String {
    var normalizedSearchText: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .autoupdatingCurrent)
            .lowercased()
    }

    var searchWords: [String] {
        components(separatedBy: CharacterSet.alphanumerics.inverted.subtracting(CharacterSet(charactersIn: "+:-")))
            .filter { $0.isEmpty == false }
    }
}
