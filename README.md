# Adaptable Sidebar Sheet

Display a sheet that can be displayed as a sidebar on iPad in SwiftUI.

> Note: This package is still a work in progress, and not everything may
> be fully documented. Proceed with caution!

This package provides a view that displays a sheet similar to Apple Maps
that can also be presented as a sidebar on wider size classes.

## Get started

Clone this repository via `git clone` or add the following dependency to
your package or project:

```swift
dependencies: [
    .package(url: "https://github.com/alicerunsonfedora/adaptablesidebarsheetview", branch: "main")
]
```

## Using the package

To display this view in your SwiftUI project, import the package and add
an `AdaptableSidebarSheet`:

```swift
import AdaptableSidebarSheetView
import SwiftUI

struct MyView: View {
    var body: some View {
        AdaptableSidebarSheet {
            mainContent
        } sheet: {
            sheet
        }
    }

    private var mainContent: some View { ... }
    private var sheet: some View { 
        mySheet
            .presentationDetents([.medium, .large])
    }
}
```

### Custom sidebar widths

The sidebar sheet is configured to display the sidebar at a width similar
to UIKit's UISplitViewController's sidebar. This can be adjusted with the
`preferredSidebarWidthFraction` argument in the view's initializer:

```swift
import AdaptableSidebarSheet
import SwiftUI

struct MyView: View {
    var body: some View {
        AdaptableSidebarSheet(preferredSidebarWidthFraction: 0.4) {
            ...
        } sheet: {
            ...
        }
    }
}
```

### Controlling presentation

The sidebar sheet can handle presentation automatically based on the
horizontal size class. However, you may wish to control this behavior
with more complex logic.

The sidebar sheet can accept a Binding to a boolean value that will be used
to handle presentation via
`init(isPresented:preferredSidebarWidthFraction:content:sheet:)`:

```swift
import AdaptableSidebarSheet
import SwiftUI

struct MyView: View {
    @State private var displaySheet = false

    var body: some View {
        AdaptableSidebarSheet(isPresented: $displaySheet) {
            ...
        } sheet: {
            ...
        }
    }
}
```

## License

AdaptableSidebarSheetView is free and open-source software under the
Mozilla Public License, v2.
