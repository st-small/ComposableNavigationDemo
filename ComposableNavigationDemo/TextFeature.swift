import ComposableArchitecture
import Foundation
import SwiftUI

struct TextFeature: Reducer {
    struct State: Hashable {
        let id = UUID()
        
        var randomText: String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
            let randomString = (0 ..< 100).map { _ in String(letters.randomElement()!) }.reduce("", +)
            return randomString
        }
    }
    enum Action { }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

struct TextView: View {
    
    let store: StoreOf<TextFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.randomText)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
