import SwiftUI
import AnyTimeCore
import UIKit

struct WorldClockHomeView: View {
    @Bindable var store: WorldClockStore
    @State private var showingPicker = false
    @State private var showingSettings = false
    @State private var pullDownMonitor = PullDownMonitor()

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                AppTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBlock(safeAreaTop: proxy.safeAreaInsets.top)
                    contentList
                }

                PullDownEasterEggView(monitor: pullDownMonitor)
                    .zIndex(1)
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .labelStyle(.iconOnly)
                .accessibilityLabel("Settings")
            }

            if #available(iOS 26.0, *) {
                ToolbarSpacer(.flexible, placement: .bottomBar)

                ToolbarItem(placement: .bottomBar) {
                    searchButton
                        .labelStyle(.iconOnly)
                }
            } else {
                ToolbarItem(placement: .status) {
                    searchButton
                }
            }
        }
        .sheet(isPresented: $showingPicker) {
            NavigationStack {
                TimeZonePickerView(store: store)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(store: store)
            }
            .presentationDetents([.medium, .large])
        }
        .animation(.snappy, value: store.favoriteTimeZoneIDs)
    }

    private var header: some View {
        Text("AnyTime")
            .font(.system(.title2, design: .rounded).weight(.bold))
            .foregroundStyle(AppTheme.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private func headerBlock(safeAreaTop: CGFloat) -> some View {
        header
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, safeAreaTop + 10)
            .padding(.bottom, 12)
            .background(AppTheme.headerSurface)
    }

    @ViewBuilder
    private var contentList: some View {
        let list = List {
            Section {
                ReferenceCalculatorCard(store: store)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                ForEach(store.presentations) { presentation in
                    clockRow(for: presentation)
                }
                .onMove(perform: store.moveTimeZones)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)

        if #available(iOS 18.0, *) {
            list.onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            }, action: { _, newValue in
                pullDownMonitor.contentOffset = newValue
            })
        } else {
            list.background {
                ScrollViewOffsetObserver { offset in
                    pullDownMonitor.contentOffset = offset
                }
            }
        }
    }

    private func clockRow(for presentation: ClockPresentation) -> some View {
        ClockCardView(presentation: presentation)
            .equatable()
            .contentShape(Rectangle())
            .onTapGesture {
                guard presentation.isReference == false else {
                    return
                }
                withAnimation(.snappy) {
                    store.setReferenceTimeZone(id: presentation.timeZoneID)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                if presentation.isReference == false {
                    Button("Reference", systemImage: "arrow.up.to.line") {
                        withAnimation(.snappy) {
                            store.setReferenceTimeZone(id: presentation.timeZoneID)
                        }
                    }
                    .tint(AppTheme.accent)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Copy", systemImage: "doc.on.doc") {
                    UIPasteboard.general.string = presentation.copyText
                }
                .tint(AppTheme.accent)

                if store.hasMultipleFavorites {
                    Button("Remove", systemImage: "trash") {
                        withAnimation(.snappy) {
                            store.removeTimeZone(id: presentation.timeZoneID)
                        }
                    }
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    private var searchButton: some View {
        Button {
            showingPicker = true
        } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
        .accessibilityLabel("Search time zones")
    }
}
