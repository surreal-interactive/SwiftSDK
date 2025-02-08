import RealityKit
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    var left_model = ModelEntity(
        mesh: .generateBox(size: 0.05),
        materials: [SimpleMaterial(color: .red, isMetallic: false)])
    var right_model = ModelEntity(
        mesh: .generateBox(size: 0.05),
        materials: [SimpleMaterial(color: .blue, isMetallic: false)])
    let headAnchorRoot: Entity = Entity()
    var body: some View {
        RealityView { content in
            headAnchorRoot.addChild(left_model)
            headAnchorRoot.addChild(right_model)
            content.add(headAnchorRoot)
        }
        update: { content in
            left_model.transform.translation = appModel.left_translation
            left_model.transform.rotation = appModel.left_rotation
            right_model.transform.translation = appModel.right_translation
            right_model.transform.rotation = appModel.right_rotation
        }
    }
}
