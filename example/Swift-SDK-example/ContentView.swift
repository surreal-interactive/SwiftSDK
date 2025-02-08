

import SwiftUI
import RealityKit
import SurrealInteractiveSDK

struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(AppModel.self) var appModel: AppModel
    
    var body: some View {
        VStack {
            SampleView()
                .environment(appModel)
                .onAppear() {
                Task {
                    await openImmersiveSpace(id: "TestSpace")
                }
            }
        }
        .ignoresSafeArea()
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
