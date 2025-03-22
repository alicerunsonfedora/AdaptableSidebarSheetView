//
//  Color+SystemBackground.swift
//  AdaptableSidebarSheetView
//
//  Created by Marquis Kurt on 22-03-2025.
//

import SwiftUI

extension Color {
    #if os(iOS)
    /// A color that corresponds to the system background (`UIColor.systemBackground`).
    static let systemBackground: Color = Color(uiColor: .systemBackground)
    #endif
}
