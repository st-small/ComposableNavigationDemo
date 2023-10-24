import ComposableArchitecture
import SwiftUI

enum Tab {
    case first, second, third
}

struct TabFeature: Reducer {
    struct State: Equatable { 
        var firstRoot = RootFeature.State()
        var secondRoot = RootFeature.State()
        var thirdRoot = RootFeature.State()
        var selectedTab: Tab = .first
    }
    
    enum Action {
        case firstRoot(RootFeature.Action)
        case secondRoot(RootFeature.Action)
        case thirdRoot(RootFeature.Action)
        case selectedTabChanged(Tab)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.firstRoot, action: /Action.firstRoot) {
            RootFeature()
        }
        Scope(state: \.secondRoot, action: /Action.secondRoot) {
            RootFeature()
        }
        Scope(state: \.thirdRoot, action: /Action.thirdRoot) {
            RootFeature()
        }
    }
}

struct TabFeatureView: View {
    let store: StoreOf<TabFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0.selectedTab},
                send: TabFeature.Action.selectedTabChanged
            )) {
                RootView(store: store.scope(
                    state: \.firstRoot,
                    action: TabFeature.Action.firstRoot)
                )
                .tabItem { Text("First") }
                .tag(Tab.first)
                
                RootView(store: store.scope(
                    state: \.secondRoot,
                    action: TabFeature.Action.secondRoot)
                )
                .tabItem { Text("Second") }
                .tag(Tab.second)
                
                RootView(store: store.scope(
                    state: \.thirdRoot,
                    action: TabFeature.Action.thirdRoot)
                )
                .tabItem { Text("Third") }
                .tag(Tab.third)
            }
        }
    }
}
