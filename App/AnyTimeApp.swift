import AnyTimeCore
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

@main
struct AnyTimeApp: App {
    @State private var store = WorldClockStore()
    @State private var locationTimeZoneMonitor = LocationTimeZoneMonitor()
    @State private var showingSettings = false
    @State private var didApplyScreenshotScenario = false

    init() {
        #if canImport(UIKit)
        UIWindow.appearance().backgroundColor = UIColor(AppTheme.backgroundTop)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                NavigationStack {
                    WorldClockHomeView(
                        store: store,
                        showingSettings: $showingSettings,
                        currentLocationTimeZoneID: locationTimeZoneMonitor.currentTimeZoneID,
                        currentLocationCityName: locationTimeZoneMonitor.currentCityName,
                        requestCurrentLocation: {
                            locationTimeZoneMonitor.requestCurrentLocation()
                        }
                    )
                }
            }
            #if os(iOS)
            .background(WindowBackgroundConfigurator())
            #elseif os(macOS)
            .background(MacWindowConfigurator())
            .frame(minWidth: 420, minHeight: 780)
            #endif
            .task {
                locationTimeZoneMonitor.refreshIfAuthorized()

                guard didApplyScreenshotScenario == false else {
                    return
                }

                didApplyScreenshotScenario = true

                if let referenceDate = AppStoreScreenshotScenario.referenceDate {
                    store.referenceDate = referenceDate
                }
            }
        }
        #if os(macOS)
        .defaultSize(width: 420, height: 780)
        #endif
        #if os(macOS)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    showingSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        #endif
    }
}

#if os(iOS)
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
#endif

#if os(macOS)
private struct MacWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configureWindow(for: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configureWindow(for: nsView)
        }
    }

    private func configureWindow(for view: NSView) {
        guard let window = view.window else {
            return
        }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
    }
}
#endif
