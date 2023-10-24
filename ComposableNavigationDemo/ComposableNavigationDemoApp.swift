import ComposableArchitecture
import SwiftUI

@main
struct ComposableNavigationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TabFeatureView(
                store: Store(
                    initialState: TabFeature.State()
                ) {
                    TabFeature()
                }
            )
        }
    }
}
