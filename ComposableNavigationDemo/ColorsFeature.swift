import ComposableArchitecture
import Foundation
import SwiftUI

struct ColorsFeature: Reducer {
    struct State: Hashable {
        let id = UUID()
        
        var randomColor: Color {
            let red = Double.random(in: 0...1)
            let green = Double.random(in: 0...1)
            let blue = Double.random(in: 0...1)
            
            return Color(red: red, green: green, blue: blue)
        }
    }
    enum Action { }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

struct ColorsView: View {
    
    let store: StoreOf<ColorsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            viewStore.randomColor.ignoresSafeArea()
        }
    }
}
