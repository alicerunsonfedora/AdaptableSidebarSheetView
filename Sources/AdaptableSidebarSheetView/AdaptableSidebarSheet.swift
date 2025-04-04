//
//  AdaptableSidebarSheetView.swift
//  MCMaps
//
//  Created by Marquis Kurt on 02-02-2025.
//

import SwiftUI

#if os(iOS)
    /// A view that displays content as a sidebar or as a sheet based on the device's horizontal size class.
    ///
    /// This view is used to construct the interface in the iOS and iPadOS versions of the app. When this view has a
    /// `regular` size class, the interface is displayed as a floating sidebar on the left hand side of the window, which
    /// can be adjusted at three different sizing breakpoints.
    ///
    /// In the `compact` size class, the interface is displayed as a sheet at the bottom of the screen, which can be
    /// adjusted if `presentationDetents` are defined on the view that is displayed as a sheet:
    ///
    /// ```swift
    /// AdaptableSidebarSheet {
    ///     MainView()
    /// } sheet: {
    ///     MySheet()
    ///         .presentationDetents([.fraction(0.1), .medium, .large])
    /// }
    /// ```
    @available(iOS 18.0, *)
    public struct AdaptableSidebarSheet<Content: View, Sheet: View>: View {
        @Binding private var sheetDisplayed: Bool
        @State private var sheetDisplayedInternally = false

        /// The preferred width fraction for the sidebar when it is presented as a sidebar.
        ///
        /// - SeeAlso: This should be treated like `UISplitViewController.preferredPrimaryColumnWidthFraction`.
        public var preferredSidebarWidthFraction = 0.317

        /// The view content that appears as the "background" or main content, that the sidebar sheet sits on top of.
        public var content: () -> Content

        /// The view content that appears as the sidebar sheet.
        public var sheet: () -> Sheet

        /// Creates an adaptable sidebar sheet that manages its own presentation.
        /// - Parameter preferredSidebarWidthFraction: The preferred width fraction for the sidebar when it is presented as
        ///   a sidebar.
        /// - Parameter content: The view content that appears as the "background" or main content, that the sidebar sheet
        ///   sits on top of.
        /// - Parameter sheet: The view content that appears as the sidebar sheet.
        public init(
            preferredSidebarWidthFraction: Double = 0.317,
            content: @escaping () -> Content,
            sheet: @escaping () -> Sheet
        ) {
            self.sheetDisplayedInternally = false
            self._sheetDisplayed = .init(projectedValue: .constant(false))
            self.preferredSidebarWidthFraction = preferredSidebarWidthFraction
            self.content = content
            self.sheet = sheet
            self._sheetDisplayed = $sheetDisplayedInternally
        }

        /// Creates an adaptable sidebar sheet where presentation is managed externally.
        /// - Parameter isPresented: Whether the view should be presented as a sheet.
        /// - Parameter preferredSidebarWidthFraction: The preferred width fraction for the sidebar when it is presented as
        ///   a sidebar.
        /// - Parameter content: The view content that appears as the "background" or main content, that the sidebar sheet
        ///   sits on top of.
        /// - Parameter sheet: The view content that appears as the sidebar sheet.
        public init(
            isPresented: Binding<Bool>,
            preferredSidebarWidthFraction: Double = 0.317,
            content: @escaping () -> Content,
            sheet: @escaping () -> Sheet
        ) {
            self._sheetDisplayed = isPresented
            self.preferredSidebarWidthFraction = preferredSidebarWidthFraction
            self.content = content
            self.sheet = sheet
        }

        public var body: some View {
            AdaptableSidebarSheetInternalView(
                sheetDisplayed: $sheetDisplayed,
                preferredSidebarWidthFraction: preferredSidebarWidthFraction,
                content: content,
                sheet: sheet
            )
        }
    }

    struct AdaptableSidebarSheetInternalView<Content: View, Sheet: View>: View {
        enum Breakpoint {
            case small, medium, large
        }
        @State private var currentBreakpoint = Breakpoint.small
        @State private var eligibleToResize = true
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @Binding var sheetDisplayed: Bool

        var preferredSidebarWidthFraction: CGFloat
        var content: () -> Content
        var sheet: () -> Sheet

        private var dragGesture: some Gesture {
            let shorthandMin = 32.0
            let shorthandMax = 48.0
            let longhandMin = 128.0
            let longhandMax = 256.0
    
            let positiveShorthand: ClosedRange<CGFloat>
            let negativeShorthand: ClosedRange<CGFloat>
            let positiveLonghand: ClosedRange<CGFloat>
            let negativeLonghand: ClosedRange<CGFloat>

            if horizontalSizeClass == .regular {
                positiveShorthand = shorthandMin...shorthandMax
                negativeShorthand = -shorthandMax ... -shorthandMin
                positiveLonghand = longhandMin ... longhandMax
                negativeLonghand = -longhandMax ... -longhandMin
            } else {
                positiveShorthand = -shorthandMax ... -shorthandMin
                negativeShorthand = shorthandMin ... shorthandMax
                positiveLonghand = -longhandMax ... -longhandMin
                negativeLonghand = longhandMin ... longhandMax
            }

            return DragGesture(minimumDistance: shorthandMin / 2)
                .onChanged { value in
                    if !eligibleToResize { return }
                    let height = value.translation.height
                    switch (currentBreakpoint, height) {
                    case (.small, positiveShorthand), (.large, negativeShorthand):
                        withAnimation(.spring) {
                            eligibleToResize = false
                            currentBreakpoint = .medium
                        } completion: {
                            eligibleToResize = true
                        }
                    case (.medium, positiveLonghand):
                        withAnimation(.spring) {
                            eligibleToResize = false
                            currentBreakpoint = .large
                        } completion: {
                            eligibleToResize = true
                        }
                    case (.large, negativeLonghand), (.medium, negativeShorthand):
                        withAnimation(.spring) {
                            eligibleToResize = false
                            currentBreakpoint = .small
                        } completion: {
                            eligibleToResize = true
                        }
                    default:
                        break
                    }
                }
        }

        var body: some View {
            Group {
                switch (horizontalSizeClass, sheetDisplayed) {
                case (.compact, true):
                    sheetLayout
                case (.regular, _):
                    sidebarLayout
                default:
                    content()
                }
            }
            .task {
                do {
                    try await Task.sleep(for: .seconds(1))
                    sheetDisplayed = horizontalSizeClass == .compact
                } catch {
                    print("Failed to wait.")
                }
            }
            .onChange(of: horizontalSizeClass) { oldValue, newValue in
                if oldValue != newValue {
                    Task {
                        do {
                            try await Task.sleep(for: .seconds(1))
                            sheetDisplayed = newValue == .compact
                        } catch {
                            print("Failed to wait.")
                        }
                    }
                }
            }
            .onDisappear {
                sheetDisplayed = false
            }
        }

        private var sidebarLayout: some View {
            GeometryReader { proxy in
                HStack {
                    VStack {
                        VStack {
                            sheet()
                                .frame(maxHeight: height(relativeTo: proxy))
                            Capsule()
                                .fill(.secondary.opacity(0.5))
                                .frame(width: 64, height: 8)
                                .gesture(dragGesture)
                        }
                        .padding(.vertical)
                        #if os(iOS)
                            .background(Color.systemBackground)
                        #endif
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                    .frame(width: proxy.size.width * preferredSidebarWidthFraction)
                    .shadow(radius: 2)
                    .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background {
                    content()
                }
            }
        }

        private var sheetLayout: some View {
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    VStack {
                        Capsule()
                            .fill(.secondary.opacity(0.5))
                            .frame(width: 48, height: 8)
                            .gesture(dragGesture)
                        sheet()
                            .frame(maxHeight: height(relativeTo: proxy))
                    }
                    .padding(.vertical)
                    #if os(iOS)
                    .background(Color.systemBackground)
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .shadow(radius: 2)
                .ignoresSafeArea(edges: .bottom)
                .background {
                    ZStack {
                        content()
                        if currentBreakpoint == .large {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                        }
                    }
                }
            }
        }

        private func height(relativeTo proxy: GeometryProxy) -> CGFloat {
            return switch currentBreakpoint {
            case .small:
                108
            case .medium:
                proxy.size.height * 0.5
            case .large:
                .infinity
            }
        }
    }

    extension AdaptableSidebarSheet {
        var testHooks: TestHooks { TestHooks(target: self) }

        @MainActor
        struct TestHooks {
            private let target: AdaptableSidebarSheet

            fileprivate init(target: AdaptableSidebarSheet) {
                self.target = target
            }

            var sheetDisplayedInternally: Bool {
                target.sheetDisplayedInternally
            }

            var preferredSidebarWidthFraction: Double {
                target.preferredSidebarWidthFraction
            }

            var content: () -> Content {
                target.content
            }

            var sheet: () -> Sheet {
                target.sheet
            }
        }
    }

    #Preview {
        @Previewable @State var isDisplayed = false
        AdaptableSidebarSheet(isPresented: $isDisplayed) {
            Color.blue
                .edgesIgnoringSafeArea(.all)
        } sheet: {
            NavigationStack {
                Text("Hello, world!")
                    .navigationTitle("Sample")
                    .toolbar {
                        Button("Hi!") {

                        }
                    }
            }
            .presentationDetents([.fraction(0.1), .medium, .large])
            .presentationBackgroundInteraction(.enabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
#endif
