import SwiftUI

@main
struct
Swift_SDK_example: App {
    @State var immersionState: ImmersionStyle = .mixed
    private var appModel = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(appModel)
        }
        ImmersiveSpace(id: "TestSpace") {
            //ContentView()
            ImmersiveView().environment(appModel)
        }
        .immersionStyle(selection: $immersionState, in: .mixed)
    }
}
