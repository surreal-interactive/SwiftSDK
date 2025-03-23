//
//  wrap.swift
//  SurrealTouchSDK
//

import Foundation
import simd
import QuartzCore
import surreal_interactive_openxr_framework

public enum xr {
    
    public class Session {
        internal  var session :OpaquePointer? = nil
        internal var local_space :OpaquePointer? = nil
        public init(instance: Instance) {
             var sessionCreateInfo = XrSessionCreateInfo()
             sessionCreateInfo.type = XR_TYPE_SESSION_CREATE_INFO
             sessionCreateInfo.next = nil
             sessionCreateInfo.systemId = 1
             sessionCreateInfo.createFlags = 0;
             xrCreateSession(instance.instance, &sessionCreateInfo, &session)
                
            var  referenceSpaceCI = XrReferenceSpaceCreateInfo()
            referenceSpaceCI.type = XR_TYPE_REFERENCE_SPACE_CREATE_INFO
            
            referenceSpaceCI.referenceSpaceType = XR_REFERENCE_SPACE_TYPE_LOCAL;
            referenceSpaceCI.poseInReferenceSpace = XrPosef(orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0), position: XrVector3f(x: 0.0, y: 0.0, z: 0.0))
            
            xrCreateReferenceSpace(session, &referenceSpaceCI, &local_space)
        }
        
        public func attachActionSet(actionSet : [ActionSet]) {
            var  actionSetAttachInfo =  XrSessionActionSetsAttachInfo()
            actionSetAttachInfo.type = XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO
            
            let action_set : [XrActionSet?] = actionSet.map{ action_set in
                return action_set.action_set
            }
            action_set.withUnsafeBufferPointer{ bufferPointer in
                actionSetAttachInfo.countActionSets = UInt32(action_set.count)
                actionSetAttachInfo.actionSets = bufferPointer.baseAddress;
                xrAttachSessionActionSets(session, &actionSetAttachInfo);
            }
            
        }
        
        public func syncActions(actionSet: [ActionSet]) -> XrResult {
            let active_c_action_set : [XrActiveActionSet] = actionSet.map { action_set in
                return XrActiveActionSet(actionSet: action_set.action_set, subactionPath: Path.nullPath().xr_path)
            }
            var actionsSyncInfo = XrActionsSyncInfo()
            actionsSyncInfo.type = XR_TYPE_ACTIONS_SYNC_INFO
            
            return active_c_action_set.withUnsafeBufferPointer{ bufferPointer in
                actionsSyncInfo.countActiveActionSets = UInt32(active_c_action_set.count);
                actionsSyncInfo.activeActionSets = bufferPointer.baseAddress;
                return xrSyncActions(session, &actionsSyncInfo)
            }
        }
        
        deinit {
            xrDestroySession(session)
            session = nil
        }
        
        public func renderDone(poll_timestamp: XrTime, render_finish_timestamp: XrTime) {
            xrRenderDone(session, poll_timestamp, render_finish_timestamp)
        }
    }
    
    public class Bind<T> {
        internal var action : Action<T>
        internal var path : Path
        
        public init(action: Action<T>, path: Path) {
            self.action = action
            self.path =  path
        }
    }
    
    
    public class Instance {
        nonisolated(unsafe) static let shared = Instance()
        internal  var instance :OpaquePointer? = nil
        
        private init() {
            var create_info = XrInstanceCreateInfo()
            create_info.type = XR_TYPE_INSTANCE_CREATE_INFO
            let xr_result = xrCreateInstance(&create_info, &instance);
            assert(xr_result == XR_SUCCESS)
        }
        public static func create() -> Instance {
            return shared
        }
        //
        // Most applications should use times from
        //  `FrameStream::wait` and `Action::state` instead
        //
        public func now() -> XrTime {
            return XrTime(CACurrentMediaTime() * 1e9)
        }
        
        public func createSession() -> Session {
            return Session(instance:self)
        }
        
        public func createActionSet(actionSetName: String, localizedActionSetName: String) -> ActionSet {
            return ActionSet(instance: self, actionSetName: actionSetName, localizedActionSetName: localizedActionSetName)
        }
        
        public func suggestInteractionProfileBindings(profile_path: Path, binds: [Any]) -> XrResult {
               // // Suggest bindings for the action set
               var  interactionProfileSuggestedBinding = XrInteractionProfileSuggestedBinding()
                interactionProfileSuggestedBinding.type = XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING
                interactionProfileSuggestedBinding.interactionProfile = profile_path.xr_path
                var cArray: [XrActionSuggestedBinding] = binds.map { bind in
                    switch bind.self {
                        case let boolBind as Bind<Bool>:
                            return XrActionSuggestedBinding(action: boolBind.action.action, binding: boolBind.path.xr_path)
                        case let floatBind as Bind<Float>:
                            return XrActionSuggestedBinding(action: floatBind.action.action, binding: floatBind.path.xr_path)
                        case let poseBind as Bind<Posef>:
                            return XrActionSuggestedBinding(action: poseBind.action.action, binding: poseBind.path.xr_path)
                        case let hapticBind as Bind<Haptic>:
                            return XrActionSuggestedBinding(action: hapticBind.action.action, binding: hapticBind.path.xr_path)
                        default:
                            fatalError("Unhandled bind type: \(type(of: bind))")
                    }
                }
            
                return cArray.withUnsafeBufferPointer { bufferPointer in
                    interactionProfileSuggestedBinding.suggestedBindings = bufferPointer.baseAddress
                    interactionProfileSuggestedBinding.countSuggestedBindings = UInt32(cArray.count)
                    return xrSuggestInteractionProfileBindings(instance, &interactionProfileSuggestedBinding)
                }
        }
        
        public func stringToPath(path_string:String) -> Path {
            return Path(instance:self, path_string: path_string)
        }
        
        deinit {
            xrDestroyInstance(instance)
            instance = nil
        }
    }
    
    public class ActionSet {
        internal  var action_set :OpaquePointer? = nil
        
        public init(instance: Instance, actionSetName: String, localizedActionSetName: String) {
            var actionSetCreateInfo = XrActionSetCreateInfo()
            actionSetCreateInfo.type = XR_TYPE_ACTION_SET_CREATE_INFO
            actionSetName.withCString {str_ptr in
                strncpy(&actionSetCreateInfo.actionSetName, str_ptr, Int(XR_MAX_ACTION_SET_NAME_SIZE))
            }
            localizedActionSetName.withCString { str_ptr in
                strncpy(&actionSetCreateInfo.localizedActionSetName, str_ptr, Int(XR_MAX_LOCALIZED_ACTION_SET_NAME_SIZE))
            }
            actionSetCreateInfo.priority = 0;
            let result = xrCreateActionSet(instance.instance, &actionSetCreateInfo, &self.action_set)
            
            if (result != XR_SUCCESS) {
                fatalError("CreateActionSet \(actionSetName) fails with result code \(result)")
            }
        }
        
        public func createAction<T>(name: String, localized_name: String, subaction_paths: [Path]?) -> Action<T> {
            return Action<T>(actionSet: self, name: name, localized_name: localized_name, subaction_paths: subaction_paths)
        }
        
    }
    
    
    public class Space {
        internal var relatedAction : Action<Posef>
        internal var subActionPath : Path
        internal var space : OpaquePointer? = nil
        internal var session:Session
        public init(session:Session, action:Action<Posef>, subActionPath: Path, poseInActionSpace: Posef) {
            self.relatedAction = action
            self.session = session
            // Create frame of reference for a pose action
            var  actionSpaceCI = XrActionSpaceCreateInfo()
            actionSpaceCI.type = XR_TYPE_ACTION_SPACE_CREATE_INFO
            let xr_posef = XrPosef()
            actionSpaceCI.action = action.action;
            actionSpaceCI.poseInActionSpace = xr_posef;
            actionSpaceCI.subactionPath = subActionPath.xr_path
            self.subActionPath = subActionPath
            xrCreateActionSpace(session.session, &actionSpaceCI, &space);
        }
        
        public func locate(predictedDisplayTime:XrTime) -> (pose:Posef, velocity: Velocityf)? {
            var actionStateGetInfo = XrActionStateGetInfo()
            actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
            // We pose a single Action, twice - once for each subAction Path.
            actionStateGetInfo.action = relatedAction.action
            // For each hand, get the pose state if possible.
           
            actionStateGetInfo.subactionPath = subActionPath.xr_path
            var pose_state = XrActionStatePose()
            xrGetActionStatePose(session.session, &actionStateGetInfo, &pose_state)
            
            if pose_state.isActive != 0 {
                var spaceVelocity = XrSpaceVelocity()
                spaceVelocity.type = XR_TYPE_SPACE_VELOCITY
                var spaceLocation = XrSpaceLocation()
                spaceLocation.type = XR_TYPE_SPACE_LOCATION
                
                var spaceVelocityPtr = UnsafeMutableRawPointer(mutating: &spaceVelocity)
                spaceLocation.next = spaceVelocityPtr
                let res : XrResult =
                xrLocateSpace(self.space, session.local_space, predictedDisplayTime, &spaceLocation);
                
                var pose_res : Posef? = nil
                var velocity_res : Velocityf? = nil
                if res == XR_SUCCESS {
                    
                if (spaceLocation.locationFlags & XR_SPACE_LOCATION_ORIENTATION_VALID_BIT != 0 ) && (spaceLocation.locationFlags & XR_SPACE_LOCATION_POSITION_VALID_BIT != 0) {
                    let orientation = spaceLocation.pose.orientation
                    let position = spaceLocation.pose.position
                    pose_res =  Posef(
                        rotation:simd_quatf(ix: orientation.x, iy: orientation.y, iz: orientation.z, r: orientation.w),
                        translation: simd_float3(position.x, position.y, position.z)
                    )
                }
                    
                    if (spaceVelocity.velocityFlags & XR_SPACE_VELOCITY_LINEAR_VALID_BIT != 0) && (spaceVelocity.velocityFlags & XR_SPACE_VELOCITY_ANGULAR_VALID_BIT != 0) {
                        velocity_res = Velocityf(linear_velocity: simd_float3(spaceVelocity.linearVelocity.x, spaceVelocity.linearVelocity.y, spaceVelocity.linearVelocity.z), angular_velocity: simd_float3(spaceVelocity.angularVelocity.x, spaceVelocity.angularVelocity.y, spaceVelocity.angularVelocity.z))
                    }
                }
                
                if let pose = pose_res, let vec = velocity_res {
                    return (pose, vec)
                }
                
            }
            return nil
        }
        
    }
    
    public class Action<T> {
        internal  var action :OpaquePointer? = nil
        public init(actionSet:ActionSet, name: String, localized_name: String, subaction_paths: [Path]?) {
             var action_ci = XrActionCreateInfo()
             action_ci.type = XR_TYPE_ACTION_CREATE_INFO;
             switch T.self {
                    case is Float.Type:
                 action_ci.actionType =  XR_ACTION_TYPE_FLOAT_INPUT
                    case is Bool.Type:
                 action_ci.actionType = XR_ACTION_TYPE_BOOLEAN_INPUT
                    case is Posef.Type:
                 action_ci.actionType = XR_ACTION_TYPE_POSE_INPUT
                    default:
                 action_ci.actionType =  XR_ACTION_TYPE_MAX_ENUM // Replace with the default XrActionType
            }
            name.withCString { basePointer in
                strncpy(&action_ci.actionName, basePointer, Int(XR_MAX_ACTION_NAME_SIZE));
            }
            localized_name.withCString { basePointer in
                strncpy(&action_ci.localizedActionName, basePointer, Int(XR_MAX_LOCALIZED_ACTION_NAME_SIZE));
            }
            
            if let paths = subaction_paths {
                let c_subaction_paths : [XrPath] = paths.map{ path in
                    return path.xr_path
                }
                c_subaction_paths.withUnsafeBufferPointer{ pointer in
                    action_ci.countSubactionPaths = UInt32(paths.count)
                    action_ci.subactionPaths = pointer.baseAddress
                    var result = xrCreateAction(actionSet.action_set, &action_ci, &action)
                    if (result != XR_SUCCESS) {
                        fatalError("CreateAction \(action_ci.actionName) fails with result code \(result)")
                    }
                }
            } else {
                action_ci.countSubactionPaths = 0
                var result = xrCreateAction(actionSet.action_set, &action_ci, &action)
                if (result != XR_SUCCESS) {
                    fatalError("CreateAction \(action_ci.actionName) fails with result code \(result)")
                }
            }
            
        }
    }
    
   
    
    public class Path {
        internal var xr_path : XrPath
        
        public init(instance:Instance, path_string:String) {
            self.xr_path = XrPath(XR_NULL_PATH)
            var result = xrStringToPath(instance.instance, path_string, &self.xr_path)
            
            if (result != XR_SUCCESS) {
                fatalError("\(path_string) fails to XrPath")
            }
            
            if (xr_path == XR_NULL_PATH) {
                fatalError("xr_paht is \(xr_path) fails to XrPath")
            }
            
        }
        
        private init() {
            self.xr_path = XrPath(XR_NULL_PATH)
        }
        public static func nullPath() -> Path {
            return Path()
        }
    }
    
    public class Haptic {
        
    }
   
    public class Posef {
        public var rotation : simd_quatf
        public var translation: simd_float3
        
        public init(rotation: simd_quatf, translation: simd_float3) {
            self.rotation = rotation
            self.translation = translation
        }
        
        public static func Identity() -> Posef {
            return Posef(rotation:simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0), translation:simd_float3(0.0, 0.0, 0.0))
        }
    }
    
    public class Velocityf {
        public var linear_velocity:simd_float3
        public var angular_velocity:simd_float3
        
        public init(linear_velocity:simd_float3, angular_velocity:simd_float3) {
            self.angular_velocity = angular_velocity
            self.linear_velocity = linear_velocity
        }
    }
}

public func HelloWorld() -> String {
    return "wrap String"
}

extension xr.Action where T == xr.Posef {
    public func createSpace(session:xr.Session, path: xr.Path, poseInReference: xr.Posef) -> xr.Space {
        return xr.Space(session:session, action: self, subActionPath:xr.Path.nullPath(), poseInActionSpace: poseInReference)
    }
}



extension xr.Action where T == Bool {
    public func getValue(session: xr.Session, path: xr.Path) -> Bool {
        var actionStateGetInfo = XrActionStateGetInfo()
        actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
        actionStateGetInfo.action = self.action;
        actionStateGetInfo.subactionPath = path.xr_path
        var state = XrActionStateBoolean()
        state.type = XR_TYPE_ACTION_STATE_BOOLEAN
        xrGetActionStateBoolean(session.session, &actionStateGetInfo, &state)
        return state.currentState != 0
    }
}

extension xr.Action where T == Bool {
    public func isActive(session:xr.Session) -> Bool {
        var actionStateGetInfo = XrActionStateGetInfo()
        actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
        actionStateGetInfo.action = self.action;
        actionStateGetInfo.subactionPath = xr.Path.nullPath().xr_path
        var state = XrActionStateBoolean()
        state.type = XR_TYPE_ACTION_STATE_BOOLEAN
        xrGetActionStateBoolean(session.session, &actionStateGetInfo, &state)
        return state.isActive != 0
    }
}


extension xr.Action where T == Float {
    public func getValue(session: xr.Session, path: xr.Path) -> Float {
        var actionStateGetInfo = XrActionStateGetInfo()
        actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
        actionStateGetInfo.action = self.action;
        actionStateGetInfo.subactionPath = path.xr_path
        var state = XrActionStateFloat()
        state.type = XR_TYPE_ACTION_STATE_FLOAT
        xrGetActionStateFloat(session.session, &actionStateGetInfo, &state)
        return state.currentState
    }
}

extension xr.Action where T == Float {
    public func isActive(session:xr.Session) -> Bool {
        var actionStateGetInfo = XrActionStateGetInfo()
        actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
        actionStateGetInfo.action = self.action;
        actionStateGetInfo.subactionPath = xr.Path.nullPath().xr_path
        var state = XrActionStateFloat()
        state.type = XR_TYPE_ACTION_STATE_FLOAT
        xrGetActionStateFloat(session.session, &actionStateGetInfo, &state)
        return state.isActive != 0
    }
}

extension xr.Action where T == xr.Posef {
    public func isActive(session:xr.Session) -> Bool {
        var actionStateGetInfo = XrActionStateGetInfo()
        actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
        actionStateGetInfo.action = self.action;
        actionStateGetInfo.subactionPath = xr.Path.nullPath().xr_path
        var state = XrActionStatePose()
        state.type = XR_TYPE_ACTION_STATE_FLOAT
        xrGetActionStatePose(session.session, &actionStateGetInfo, &state)
        return state.isActive != 0
    }
}

extension xr.Action where T == xr.Haptic {
    public func ApplyHapticFeedBack(session:xr.Session, amplitude:Float, frequency: Float, duration_in_nanoseconds: Float) -> Void {
        // TODO(junlinp): send HapticFeedBack
        var vibration = XrHapticVibration()
        vibration.type = XR_TYPE_HAPTIC_VIBRATION
        vibration.amplitude = amplitude
        vibration.duration = XrDuration(duration_in_nanoseconds);
        vibration.frequency = frequency;

        var hapticActionInfo = XrHapticActionInfo()
        hapticActionInfo.type = XR_TYPE_HAPTIC_ACTION_INFO
        hapticActionInfo.action = self.action
        hapticActionInfo.subactionPath = xr.Path.nullPath().xr_path
        withUnsafePointer(to: &vibration) { pointer in
            let basePointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: XrHapticBaseHeader.self)
            xrApplyHapticFeedback(session.session, &hapticActionInfo, basePointer)
        }
    }
}
