import SwiftUI
import AnyTimeCore
import UIKit

@main
struct AnyTimeApp: App {
    @State private var store = WorldClockStore()

    init() {
        UIWindow.appearance().backgroundColor = UIColor(AppTheme.backgroundTop)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                NavigationStack {
                    WorldClockHomeView(store: store)
                }
            }
            .background(WindowBackgroundConfigurator())
        }
    }
}

private struct WindowBackgroundConfigurator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            let fillColor = UIColor(AppTheme.backgroundTop)

            uiView.window?.backgroundColor = fillColor
            uiView.window?.rootViewController?.view.backgroundColor = fillColor

            var currentSuperview = uiView.superview
            while let superview = currentSuperview {
                superview.backgroundColor = fillColor
                currentSuperview = superview.superview
            }
        }
    }
}
