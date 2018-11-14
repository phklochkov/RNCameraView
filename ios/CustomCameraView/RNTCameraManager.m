//
//  RNTCameraManager.m
//  CustomCameraView
//
//  Created by Philip Klochkov on 10/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RNTCameraView.h"

@interface RNTCameraManager : RCTViewManager
@end

@implementation RNTCameraManager
-(void)findView:(nonnull NSNumber *)reactTag withUIBlock:(void (^)(RNTCameraView*))block
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    UIView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[RNTCameraView class]]) {
      RCTLog(@"expecting UIView, got: %@", view);
    } else {
      RNTCameraView *cameraView = (RNTCameraView *)view;
      block(cameraView);
    }
  }];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(takePhoto:(nonnull NSNumber *)reactTag takePhotoWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [self findView:reactTag withUIBlock:^(RNTCameraView *cameraView) {
     [cameraView takePhoto:resolve rejecter:reject];
   }];
}

RCT_EXPORT_METHOD(switchCamera:(nonnull NSNumber *)reactTag withPosition:(NSString *) position)
{
  [self findView:reactTag withUIBlock:^(RNTCameraView *cameraView) {
     [cameraView switchCamera:position];
   }];
}

-(UIView *)view
{
  return [RNTCameraView new];
}

@end
