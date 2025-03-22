# ``AdaptableSidebarSheet``

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

> Important: Ensure that your view will scale to fit the area for the
> sidebar. Views like `NavigationStack` are automatically handled, but
> custom views may need frame adjustments.

### Controlling presentation

The sidebar sheet can handle presentation automatically based on the
horizontal size class. However, you may wish to control this behavior
with more complex logic.

The sidebar sheet can accept a Binding to a boolean value that will be used
to handle presentation via ``init(isPresented:preferredSidebarWidthFraction:content:sheet:)``:

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
