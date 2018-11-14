import React from 'react'
import {findNodeHandle, requireNativeComponent, NativeModules} from 'react-native'

const RNTCamera = requireNativeComponent('RNTCamera', null)

const RNTCameraManager = NativeModules.RNTCameraManager

const CAMERA_POSITION = {
  FRONT: 'front',
  BACK: 'back'
}

export class CameraView extends React.Component {
  cameraRef = React.createRef()
  state = {
    cameraPosition: CAMERA_POSITION.BACK
  }

  getNodeHandle = () => findNodeHandle(this.cameraRef.current)

  takePhoto = async (imageQuality = 0.5) => {
    return RNTCameraManager.takePhoto(this.getNodeHandle(), imageQuality)
  }

  switchCamera = async () => {
    const {cameraPosition} = this.state
    const nextPosition = cameraPosition === 'back' ? 'front' : 'back'

    RNTCameraManager.switchCamera(this.getNodeHandle(), nextPosition)
    this.setState({cameraPosition: nextPosition})
  }

  render() {
    return <RNTCamera {...this.props} ref={this.cameraRef} />
  }
}
