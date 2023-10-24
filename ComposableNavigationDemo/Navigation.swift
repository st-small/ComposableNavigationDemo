import ComposableArchitecture
import SwiftUI

extension Reducer {
    public func forEach<ElementState: Identifiable, ElementAction, Element: Reducer>(
        _ toElementsState: WritableKeyPath<State, IdentifiedArrayOf<ElementState>>,
        action toStackAction: CasePath<Action, StackAction<ElementState, ElementAction>>,
        @ReducerBuilder<ElementState, ElementAction> element: () -> Element,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some ReducerOf<Self>
    where ElementState == Element.State, ElementAction == Element.Action {
        let element = element()
        
        return Reduce { state, action in
            switch toStackAction.extract(from: action) {
            case let .element(id: id, action: childAction):
                if state[keyPath: toElementsState][id: id] == nil {
                    XCTFail("Action was sent for an element that does not exist")
                    return reduce(into: &state, action: action)
                }
                
                return .merge(
                    element
                        .reduce(into: &state[keyPath: toElementsState][id: id]!, action: childAction)
                        .map { toStackAction.embed(.element(id: id, action: $0)) },
                    reduce(into: &state, action: action)
                )
                
            case let .setPath(path):
                state[keyPath: toElementsState] = path
                return reduce(into: &state, action: action)
                
            case .none:
                return reduce(into: &state, action: action)
            }
        }
    }
}

public enum StackAction<State: Identifiable, Action> {
    case element(id: State.ID, action: Action)
    case setPath(IdentifiedArrayOf<State>)
}

struct NavigationStackStore<
    Root: View,
    PathState: Hashable & Identifiable,
    PathAction,
    Destination: View
>: View {
    let store: Store<IdentifiedArrayOf<PathState>, StackAction<PathState, PathAction>>
    let root: Root
    let destination: (PathState) -> Destination
    
    init(
        _ store: Store<IdentifiedArrayOf<PathState>, StackAction<PathState, PathAction>>,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destination: @escaping (PathState) -> Destination
    ) {
        self.store = store
        self.root = root()
        self.destination = destination
    }
    
    var body: some View {
        WithViewStore(
            store,
            observe: { $0 },
            removeDuplicates: { $0.ids == $1.ids }
        ) { viewStore in
            NavigationStack(
                path: viewStore.binding(
                    get: { _ in
                        ViewStore(store, observe: { $0 }).state
                    },
                    send: { .setPath($0) }
                )
            ) {
                root
                    .navigationDestination(for: PathState.self) { pathState in
                        SwitchStore(
                            store.scope(
                                state: { $0[id: pathState.id] ?? pathState },
                                action: {
                                    .element(id: pathState.id, action: $0)
                                }
                            )
                        ) { state in
                            destination(pathState)
                        }
                    }
            }
        }
    }
}
