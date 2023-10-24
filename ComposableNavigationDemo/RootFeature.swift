import ComposableArchitecture
import Foundation
import SwiftUI

struct RootFeature: Reducer {
    struct State: Equatable {
        var path: IdentifiedArrayOf<Path.State> = []
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case openColorTapped
        case openTextTapped
    }
    
    struct Path: Reducer {
        enum State: Hashable, Identifiable {
            case colors(ColorsFeature.State)
            case text(TextFeature.State)
            
            var id: AnyHashable {
                switch self {
                case let .colors(state):
                    return state.id
                case let .text(state):
                    return state.id
                }
            }
        }
        enum Action { 
            case colors(ColorsFeature.Action)
            case text(TextFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.colors, action: /Action.colors) {
                ColorsFeature()
            }
            Scope(state: /State.text, action: /Action.text) {
                TextFeature()
            }
        }
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openColorTapped:
                state.path.append(.colors(ColorsFeature.State()))
                return .none
                
            case .openTextTapped:
                state.path.append(.text(TextFeature.State()))
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}

struct RootView: View {
    
    let store: StoreOf<RootFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStackStore(
                store.scope(state: \.path, action: { .path($0) })
            ) {
                VStack(spacing: 50) {
                    Button("Open color screen") {
                        viewStore.send(.openColorTapped)
                    }
                    
                    Button("Open text string") { 
                        viewStore.send(.openTextTapped)
                    }
                }
            } destination: { state in
                switch state {
                case .colors:
                    CaseLet(
                        /RootFeature.Path.State.colors,
                        action: RootFeature.Path.Action.colors,
                        then: ColorsView.init(store:)
                    )
                case .text:
                    CaseLet(
                        /RootFeature.Path.State.text,
                        action: RootFeature.Path.Action.text,
                        then: TextView.init(store:)
                    )
                }
            }
        }
    }
}
