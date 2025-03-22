# Adaptable Sidebar Sheet View

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

### Using the package

To display this view in your SwiftUI project, import the package and add
an `AdaptableSidebarSheetView`:

```swift
import AdaptableSidebarSheetView
import SwiftUI

struct MyView: View {
    var body: some View {
        AdaptableSidebarSheetView {
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

## License

AdaptableSidebarSheetView is free and open-source software under the
Mozilla Public License, v2.
