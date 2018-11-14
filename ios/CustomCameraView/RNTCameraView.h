//
//  RNTCameraView.h
//  CustomCameraView
//
//  Created by Philip Klochkov on 10/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RNTCameraView : UIView<AVCapturePhotoCaptureDelegate>
-(void)takePhoto:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
-(void)switchCamera:(NSString*) position;
@end
