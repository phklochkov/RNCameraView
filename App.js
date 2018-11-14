import React from 'react'
import {SafeAreaView, View, TouchableOpacity, Text, Image, StatusBar, StyleSheet} from 'react-native'
import {CameraView} from './CameraView'

export default class App extends React.Component {
  cameraViewRef = React.createRef()

  state = {
    uri: null,
    cameraPosition: 'back'
  }

  takePhoto = async () => {
    const uri = await this.cameraViewRef.current.takePhoto()
    this.setState({uri})
  }

  switchCamera = () => {
    this.cameraViewRef.current.switchCamera()
  }

  render() {
    return (
      <View style={styles.container}>
        <StatusBar barStyle="light-content" />
        <SafeAreaView style={styles.topBar}>
          <TouchableOpacity onPress={() => { this.setState({uri: null}) }}>
            <Text style={{color: '#00aaed', paddingHorizontal: 15, fontSize: 22}}>{'\u2329'}</Text>
          </TouchableOpacity>
          <Text style={{color: '#fff', fontSize: 16}}>Capture photo</Text>
        </SafeAreaView>
        {this.state.uri ?
          <Image source={{uri: this.state.uri}} style={{flex: 1}} /> :
          <React.Fragment>
            <CameraView style={{flex: 0.85}} ref={this.cameraViewRef} />
            <View style={{flex: 0.15, alignItems: 'center', justifyContent: 'space-evenly', flexDirection: 'row', backgroundColor: '#000'}}>
            <TouchableOpacity onPress={this.switchCamera}>
                <View style={{width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', marginRight: 15}}></View>
              </TouchableOpacity>
              <TouchableOpacity onPress={this.takePhoto}>
                <View style={{width: 50, height: 50, borderRadius: 25, backgroundColor: '#fff'}}></View>
              </TouchableOpacity>
            </View>
          </React.Fragment>}
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {flex: 1},
  topBar: {
    height: 50,
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    position: 'absolute',
    top: 0,
    left: 0,
    zIndex: 1,
    flexDirection: 'row',
    width: '100%'
  }
})
