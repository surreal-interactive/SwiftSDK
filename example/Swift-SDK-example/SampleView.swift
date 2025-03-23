

import SwiftUI
import simd

import ARKit
import RealityKit

struct SampleView : View {
    @Environment(AppModel.self) var appModel : AppModel
    // Timer for updating states
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    @State private var enable_left_haptic : Bool = false
    @State private var enable_right_haptic : Bool = false
    var body: some View {
        VStack {
            
            VStack() {
                // Left controller inputs
                HStack {
                    Toggle("Send Left Controller Hapic", isOn: $enable_left_haptic)
                        .padding()
                        .onChange(of: enable_left_haptic) { newValue in
                            appModel.enable_left_haptic = newValue
                        }
                    Toggle("Send Right Controller Hapic", isOn: $enable_right_haptic)
                        .padding()
                        .onChange(of: enable_right_haptic) { newValue in
                            appModel.enable_right_haptic = newValue
                        }
                }
                HStack {
                    VStack {
                        Text("Left Controller:")
                        HStack {
                            VStack {
                                Text("X: \(appModel.left_x_state ? "Pressed" : "Released")")
                                Text("Y: \(appModel.left_y_state ? "Pressed" : "Released")")
                                Text("ThumbStick: \(appModel.left_thumb_stick_z_state ? "Pressed" : "Released")")
                                Text("Menu: \(appModel.left_menu_state ? "Pressed" : "Released")")
                            }
                            VStack {
                                Text("Trigger: \(appModel.left_trigger_state)")
                                Text("Grip: \(appModel.left_grip_state)")
                                Text("ThumbStick X: \(appModel.left_thumbstick_x_state)")
                                Text("ThumbStick Y: \(appModel.left_thumbstick_y_state)")
                            }
                        }
                    }
                    // Right controller inputs
                    VStack {
                        Text("Right Controller:")
                        HStack {
                            VStack {
                                Text("A: \(appModel.right_a_state ? "Pressed" : "Released")")
                                Text("B: \(appModel.right_b_state ? "Pressed" : "Released")")
                                Text("ThumbStick: \(appModel.right_thumb_stick_z_state ? "Pressed" : "Released")")
                                Text("Menu: \(appModel.right_menu_state ? "Pressed" : "Released")")
                            }
                            VStack {
                                Text("Trigger: \(appModel.right_trigger_state)")
                                Text("Grip: \(appModel.right_grip_state)")
                                Text("ThumbStick X: \(appModel.right_thumbstick_x_state)")
                                Text("ThumbStick Y: \(appModel.right_thumbstick_y_state)")
                            }
                        }
                    }
                }
                HStack {
                    // Left controller pose
                    VStack {
                        Text("Left Controller Pose:")
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Position:")
                                Text("X: \(String(format: "%.3f", appModel.left_translation.x))")
                                Text("Y: \(String(format: "%.3f", appModel.left_translation.y))")
                                Text("Z: \(String(format: "%.3f", appModel.left_translation.z))")
                                
                            }
                            VStack(alignment: .leading) {
                                Text("Orientation:")
                                Text("X: \(String(format: "%.3f", appModel.left_rotation.imag.x))")
                                Text("Y: \(String(format: "%.3f", appModel.left_rotation.imag.y))")
                                Text("Z: \(String(format: "%.3f", appModel.left_rotation.imag.z))")
                                Text("W: \(String(format: "%.3f", appModel.left_rotation.real))")
                                
                            }
                            VStack(alignment: .leading) {
                                Text("Velocity:")
                                Text("Lienar_X: \(String(format: "%.3f", appModel.left_linear_velocity.x))")
                                Text("Lienar_Y: \(String(format: "%.3f", appModel.left_linear_velocity.y))")
                                Text("Lienar_Z: \(String(format: "%.3f", appModel.left_linear_velocity.z))")
                                Text("Angular_X: \(String(format: "%.3f", appModel.left_angular_velocity.x))")
                                Text("Angular_Y: \(String(format: "%.3f", appModel.left_angular_velocity.y))")
                                Text("Angular_Z: \(String(format: "%.3f", appModel.left_angular_velocity.z))")
                                
                            }
                        }
                    }
                    VStack {
                        // Right controller pose
                        Text("Right Controller Pose:")
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Position:")
                                Text("X: \(String(format: "%.3f", appModel.right_translation.x))")
                                Text("Y: \(String(format: "%.3f", appModel.right_translation.y))")
                                Text("Z: \(String(format: "%.3f", appModel.right_translation.z))")
                                
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Orientation:")
                                
                                Text("X: \(String(format: "%.3f", appModel.right_rotation.imag.x))")
                                Text("Y: \(String(format: "%.3f", appModel.right_rotation.imag.y))")
                                Text("Z: \(String(format: "%.3f", appModel.right_rotation.imag.z))")
                                Text("W: \(String(format: "%.3f", appModel.right_rotation.real))")
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Velocity:")
                                Text("Lienar_X: \(String(format: "%.3f", appModel.right_linear_velocity.x))")
                                Text("Lienar_Y: \(String(format: "%.3f", appModel.right_linear_velocity.y))")
                                Text("Lienar_Z: \(String(format: "%.3f", appModel.right_linear_velocity.z))")
                                Text("Angular_X: \(String(format: "%.3f", appModel.right_angular_velocity.x))")
                                Text("Angular_Y: \(String(format: "%.3f", appModel.right_angular_velocity.y))")
                                Text("Angular_Z: \(String(format: "%.3f", appModel.right_angular_velocity.z))")
                            }
                            
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
        .onReceive(timer) {[self] _ in
            appModel.Update()
        }
    }
}

