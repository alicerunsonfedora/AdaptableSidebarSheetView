import SwiftUI
import Testing
import ViewInspector

@testable import AdaptableSidebarSheetView

@MainActor
struct AdaptableSidebarSheetViewTests {
    @Test func viewInitialize() throws {
        let content = {
            return Text("Background!")
        }
        let sheet = {
            return Text("Foreground!")
        }
        let view = AdaptableSidebarSheet(content: content, sheet: sheet)
        let hooks = view.testHooks

        #expect(hooks.sheetDisplayedInternally == false)
        #expect(hooks.preferredSidebarWidthFraction == 0.317)

        let contentExpectSut = try content().inspect()
        let contentActualSut = try view.content().inspect()
        #expect(try contentActualSut.text().string() == contentExpectSut.text().string())
    }

    @Test func viewInitializeWithBinding() throws {
        let isPresented = Binding<Bool>(wrappedValue: false)
        let detent = Binding<AdaptableSidebarSheetBreakpoint>(wrappedValue: .small)
        let content = {
            return Text("Background!")
        }
        let sheet = {
            return Text("Foreground!")
        }
        let view = AdaptableSidebarSheet(
            isPresented: isPresented,
            currentPresentationDetent: detent,
            content: content,
            sheet: sheet
        )
        let hooks = view.testHooks

        #expect(hooks.sheetDisplayedInternally == isPresented.wrappedValue)
        #expect(hooks.preferredSidebarWidthFraction == 0.317)

        let contentExpectSut = try content().inspect()
        let contentActualSut = try view.content().inspect()
        #expect(try contentActualSut.text().string() == contentExpectSut.text().string())
    }
}
