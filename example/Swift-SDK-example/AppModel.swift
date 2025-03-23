
import SwiftUI
import RealityKit
import ARKit
import SurrealInteractiveSDK
import surreal_interactive_openxr_framework
import Observation

@MainActor
@Observable
class AppModel {
    // Store actions and session as properties so they can be accessed in body
    private var instance: xr.Instance
    private var session: xr.Session
    private var action_set: xr.ActionSet
    
    // Button actions
    private var left_x_action: xr.Action<Bool>
    private var left_y_action: xr.Action<Bool>
    private var left_thumbstick_z_action: xr.Action<Bool>
    private var left_menu_action: xr.Action<Bool>
    
    private var right_a_action: xr.Action<Bool>
    private var right_b_action: xr.Action<Bool>
    private var right_thumbstick_z_action: xr.Action<Bool>
    private var right_menu_action: xr.Action<Bool>
    
    // Analog inputs
    private var left_trigger_action: xr.Action<Float>
    private var left_grip_action: xr.Action<Float>
    private var left_thumbstick_x_action: xr.Action<Float>
    private var left_thumbstick_y_action: xr.Action<Float>
    
    private var right_trigger_action: xr.Action<Float>
    private var right_grip_action: xr.Action<Float>
    private var right_thumbstick_x_action: xr.Action<Float>
    private var right_thumbstick_y_action: xr.Action<Float>
    
    // Pose actions for controller positions
    private var left_pose_action: xr.Action<xr.Posef>
    private var left_pose_space : xr.Space
    private var right_pose_action: xr.Action<xr.Posef>
    private var right_pose_space : xr.Space
    
    private var left_haptic_action : xr.Action<xr.Haptic>
    private var right_haptic_action : xr.Action<xr.Haptic>
    private var left_haptic_last_timestamp : Int64 = 0
    private var right_haptic_last_timestamp : Int64 = 0
    
    // States for button actions
    var left_x_state = false
    var left_y_state = false
    var left_thumb_stick_z_state = false
    var left_menu_state = false
    
      var right_a_state = false
      var right_b_state = false
      var right_thumb_stick_z_state = false
     var right_menu_state = false
    
    // States for analog inputs
      var left_trigger_state: Float = 0.0
      var left_grip_state: Float = 0.0
      var left_thumbstick_x_state: Float = 0.0
     var left_thumbstick_y_state: Float = 0.0
    
      var right_trigger_state: Float = 0.0
      var right_grip_state: Float = 0.0
      var right_thumbstick_x_state: Float = 0.0
      var right_thumbstick_y_state: Float = 0.0
    
     var left_translation =   simd_float3(0.0, 0.0, 0.0)
     var left_rotation = simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0)
     var left_linear_velocity = simd_float3(0.0, 0.0, 0.0)
     var left_angular_velocity = simd_float3(0.0, 0.0, 0.0)
    
    
     var right_translation =   simd_float3(0.0, 0.0, 0.0)
     var right_rotation = simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0)
     var right_linear_velocity = simd_float3(0.0, 0.0, 0.0)
     var right_angular_velocity = simd_float3(0.0, 0.0, 0.0)
    
     var enable_left_haptic : Bool = false
     var enable_right_haptic : Bool = false
    
    public init() {
        let xr_instance : xr.Instance = xr.Instance.create()
        let xr_session = xr_instance.createSession()
        let xr_action_set = xr_instance.createActionSet(actionSetName: "ControllerInput", localizedActionSetName: "Controller Input Set")
        
        // Initialize button actions
        let xr_left_x_action = xr_action_set.createAction(name: "left_x", localized_name: "Left X Button", subaction_paths: nil) as xr.Action<Bool>
        let xr_left_y_action = xr_action_set.createAction(name: "left_y", localized_name: "Left Y Button", subaction_paths: nil) as xr.Action<Bool>
        let xr_left_thumbstick_z_action = xr_action_set.createAction(name: "thumbstick_z", localized_name: "thumbstick_z", subaction_paths: [
            xr_instance.stringToPath(path_string:  "/user/hand/left/input/thumbstick/click")
        ]) as xr.Action<Bool>
        
        let xr_left_menu_action = xr_action_set.createAction(name: "left_menu", localized_name: "Left Menu Button", subaction_paths: nil) as xr.Action<Bool>
        
        let xr_right_a_action = xr_action_set.createAction(name: "right_a", localized_name: "Right A Button", subaction_paths: nil) as xr.Action<Bool>
        let xr_right_b_action = xr_action_set.createAction(name: "right_b", localized_name: "Right B Button", subaction_paths: nil) as xr.Action<Bool>
        let xr_right_thumbstick_z_action = xr_action_set.createAction(name: "thumbstick_z", localized_name: "thumbstick_z", subaction_paths: [
            xr_instance.stringToPath(path_string:  "/user/hand/right/input/thumbstick/click")]) as xr.Action<Bool>
        
        let xr_right_menu_action = xr_action_set.createAction(name: "right_menu", localized_name: "Right Menu Button", subaction_paths: nil) as xr.Action<Bool>
        
        // Initialize analog inputs
        let xr_left_trigger_action = xr_action_set.createAction(name: "left_trigger", localized_name: "Left Trigger", subaction_paths: nil) as xr.Action<Float>
        let xr_left_grip_action = xr_action_set.createAction(name: "left_grip", localized_name: "Left Grip", subaction_paths: nil) as xr.Action<Float>
        let xr_left_thumbstick_x_action = xr_action_set.createAction(name: "left_thumbstick_x", localized_name: "Left Thumbstick X", subaction_paths: nil) as xr.Action<Float>
        let xr_left_thumbstick_y_action = xr_action_set.createAction(name: "left_thumbstick_y", localized_name: "Left Thumbstick Y", subaction_paths: nil) as xr.Action<Float>
        
        let xr_right_trigger_action = xr_action_set.createAction(name: "right_trigger", localized_name: "Right Trigger", subaction_paths: [xr_instance.stringToPath(path_string: "/user/hand/right/input/trigger/value")]) as xr.Action<Float>
        let xr_right_grip_action = xr_action_set.createAction(name: "right_grip", localized_name: "Right Grip", subaction_paths: nil) as xr.Action<Float>
        let xr_right_thumbstick_x_action = xr_action_set.createAction(name: "right_thumbstick_x", localized_name: "Right Thumbstick X", subaction_paths: nil) as xr.Action<Float>
        let xr_right_thumbstick_y_action = xr_action_set.createAction(name: "right_thumbstick_y", localized_name: "Right Thumbstick Y", subaction_paths: nil) as xr.Action<Float>
        
        // Initialize pose actions
        let xr_left_pose_action = xr_action_set.createAction(name: "left_pose", localized_name: "Left Pose", subaction_paths: nil) as xr.Action<xr.Posef>
        let xr_left_pose_space = xr_left_pose_action.createSpace(session: xr_session, path: xr.Path.nullPath(), poseInReference: xr.Posef.Identity())
        
        let xr_right_pose_action = xr_action_set.createAction(name: "right_pose", localized_name: "Right Pose", subaction_paths: nil) as xr.Action<xr.Posef>
        let xr_right_pose_space = xr_right_pose_action.createSpace(session: xr_session, path: xr.Path.nullPath(), poseInReference: xr.Posef.Identity())
        
        let xr_left_haptic_action = xr_action_set.createAction(name:"left_haptic", localized_name: "Left Hapic", subaction_paths: nil) as xr.Action<xr.Haptic>
        let xr_right_haptic_action = xr_action_set.createAction(name:"right_haptic", localized_name: "Right Hapic", subaction_paths: nil) as xr.Action<xr.Haptic>
        
        // Bind all actions to the interaction profile
        var _ = xr_instance.suggestInteractionProfileBindings(
            profile_path: xr_instance.stringToPath(path_string: "/interaction_profiles/surreal_interactive/surreal_touch"),
            binds: [
                // Left controller bindings
                xr.Bind(action: xr_left_x_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/x/click")),
                xr.Bind(action: xr_left_y_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/y/click")),
                xr.Bind(action: xr_left_thumbstick_z_action, path: xr_instance.stringToPath(path_string:  "/user/hand/left/input/thumbstick/click")),
                xr.Bind(action: xr_left_menu_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/menu/click")),
                xr.Bind(action: xr_left_trigger_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/trigger/value")),
                xr.Bind(action: xr_left_grip_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/squeeze/value")),
                xr.Bind(action: xr_left_thumbstick_x_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/thumbstick/x")),
                xr.Bind(action: xr_left_thumbstick_y_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/thumbstick/y")),
                xr.Bind(action: xr_left_pose_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/input/grip/pose")),
                xr.Bind(action: xr_left_haptic_action, path: xr_instance.stringToPath(path_string: "/user/hand/left/output/haptic")),
                // Right controller bindings
                xr.Bind(action: xr_right_a_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/a/click")),
                xr.Bind(action: xr_right_b_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/b/click")),
                xr.Bind(action: xr_right_thumbstick_z_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/thumbstick/click")),
                xr.Bind(action: xr_right_menu_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/menu/click")),
                xr.Bind(action: xr_right_trigger_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/trigger/value")),
                xr.Bind(action: xr_right_grip_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/squeeze/value")),
                xr.Bind(action: xr_right_thumbstick_x_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/thumbstick/x")),
                xr.Bind(action: xr_right_thumbstick_y_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/thumbstick/y")),
                xr.Bind(action: xr_right_pose_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/input/grip/pose")),
                xr.Bind(action: xr_right_haptic_action, path: xr_instance.stringToPath(path_string: "/user/hand/right/output/haptic")),
            ]
        )
        
        xr_session.attachActionSet(actionSet: [xr_action_set])
        let _ = xr_session.syncActions(actionSet:[xr_action_set])
        left_haptic_last_timestamp = 0
        right_haptic_last_timestamp = 0
        
        
        instance = xr_instance
        session = xr_session
        action_set = xr_action_set
        
        left_x_action = xr_left_x_action
        left_y_action = xr_left_y_action
        left_thumbstick_z_action = xr_left_thumbstick_z_action
        
        left_menu_action = xr_left_menu_action
        
        right_a_action = xr_right_a_action
        right_b_action = xr_right_b_action
        right_thumbstick_z_action = xr_right_thumbstick_z_action
        right_menu_action = xr_right_menu_action
        
        // Initialize analog inputs
        left_trigger_action = xr_left_trigger_action
        left_grip_action = xr_left_grip_action
        left_thumbstick_x_action = xr_left_thumbstick_x_action
        left_thumbstick_y_action =  xr_left_thumbstick_y_action
        
        right_trigger_action = xr_right_trigger_action
        
        right_grip_action = xr_right_grip_action
        
        right_thumbstick_x_action = xr_right_thumbstick_x_action
        right_thumbstick_y_action = xr_right_thumbstick_y_action
        
        // Initialize pose actions
        left_pose_action = xr_left_pose_action
        left_pose_space = xr_left_pose_space
        
        right_pose_action = xr_right_pose_action
        right_pose_space = xr_right_pose_space
        
        left_haptic_action =  xr_left_haptic_action
        right_haptic_action = xr_right_haptic_action
        
        
    }
    
    
    func Update() {
        let result : XrResult = session.syncActions(actionSet:[action_set])
        
        if result == XR_SUCCESS {
            if left_x_action.isActive(session: session) {
                left_x_state = left_x_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if left_y_action.isActive(session: session) {
                left_y_state = left_y_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if left_thumbstick_z_action.isActive(session: session) {
                left_thumb_stick_z_state = left_thumbstick_z_action.getValue(session:session, path: xr.Path.nullPath())
            }
            
            if right_a_action.isActive(session: session) {
                right_a_state = right_a_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if right_b_action.isActive(session: session) {
                right_b_state = right_b_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if right_thumbstick_z_action.isActive(session: session) {
                right_thumb_stick_z_state = right_thumbstick_z_action.getValue(session:session, path: xr.Path.nullPath())
            }
         
            if  left_menu_action.isActive(session: session) {
                left_menu_state = left_menu_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if right_menu_action.isActive(session: session) {
                right_menu_state = right_menu_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if left_trigger_action.isActive(session: session) {
                left_trigger_state = left_trigger_action.getValue(session: session, path: xr.Path.nullPath())
            }

            if left_grip_action.isActive(session: session) {
                left_grip_state = left_grip_action.getValue(session: session, path: xr.Path.nullPath())
            }
            if left_thumbstick_x_action.isActive(session: session) {
                left_thumbstick_x_state = left_thumbstick_x_action.getValue(session: session, path: xr.Path.nullPath())
            }
            if left_thumbstick_y_action.isActive(session: session) {
                left_thumbstick_y_state = left_thumbstick_y_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            if right_trigger_action.isActive(session: session) {
                right_trigger_state = right_trigger_action.getValue(session: session, path: xr.Path.nullPath())
            }
            if right_grip_action.isActive(session: session) {
                right_grip_state = right_grip_action.getValue(session: session, path: xr.Path.nullPath())
            }
            if right_thumbstick_x_action.isActive(session: session) {
                right_thumbstick_x_state = right_thumbstick_x_action.getValue(session: session, path: xr.Path.nullPath())
            }
            if right_thumbstick_y_action.isActive(session: session) {
                right_thumbstick_y_state = right_thumbstick_y_action.getValue(session: session, path: xr.Path.nullPath())
            }
            
            // Update pose states
            let current_timestamp = instance.now()
            if let left_pose_and_velocity  = left_pose_space.locate(predictedDisplayTime: current_timestamp) {
                left_rotation = left_pose_and_velocity.pose.rotation
                left_translation = left_pose_and_velocity.pose.translation
                left_linear_velocity = left_pose_and_velocity.velocity.linear_velocity
                left_angular_velocity = left_pose_and_velocity.velocity.angular_velocity
            }
            
            if let right_pose_and_velocity = right_pose_space.locate(predictedDisplayTime: current_timestamp) {
                right_rotation = right_pose_and_velocity.pose.rotation
                right_translation = right_pose_and_velocity.pose.translation
                right_linear_velocity = right_pose_and_velocity.velocity.linear_velocity
                right_angular_velocity = right_pose_and_velocity.velocity.angular_velocity
            }
            
            if current_timestamp > left_haptic_last_timestamp + 1000000000 && enable_left_haptic {
                left_haptic_last_timestamp = current_timestamp
                left_haptic_action.ApplyHapticFeedBack(session: session, amplitude: 0.8, frequency: 200, duration_in_nanoseconds: (1000 * 50))
            }
           
            if current_timestamp > right_haptic_last_timestamp + 1000000000 && enable_right_haptic {
                right_haptic_last_timestamp = current_timestamp
                right_haptic_action.ApplyHapticFeedBack(session: session, amplitude: 0.8, frequency: 200, duration_in_nanoseconds: (1000 * 50))
            }
            session.renderDone(poll_timestamp: current_timestamp, render_finish_timestamp: current_timestamp + 16666666) // assume photon after 16.6 ms
        } else {
            
        }
         
    }
}
