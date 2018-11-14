import {requireNativeComponent, NativeModules} from 'react-native'

const RNTCamera = requireNativeComponent('RNTCamera', null)

const RNTCameraManager = NativeModules.RNTCameraManager

export {RNTCamera, RNTCameraManager}
