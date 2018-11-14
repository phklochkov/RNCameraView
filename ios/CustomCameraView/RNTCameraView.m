//
//  RNTCameraView.m
//  CustomCameraView
//
//  Created by Philip Klochkov on 10/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <React/RCTViewManager.h>
#import "RNTCameraView.h"

@implementation RNTCameraView
AVCaptureSession *session;
AVCapturePhotoOutput *stillImageOutput;
AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(AVCaptureDevice*) getCaptureDevice:(AVCaptureDevicePosition) position
{
  AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
  
  return [discoverySession.devices firstObject];
}

-(void) switchCamera:(NSString*) position
{
  if (!session) {
    return;
  }
  
  [session beginConfiguration];
  
  // TODO: For now, update.
  AVCaptureDevicePosition devicePosition = [position isEqualToString:@"front"] ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
  
  // Clear existing device inputs.
  for (AVCaptureInput* input in session.inputs) {
    [session removeInput:input];
  }
  
  // Retrieve camera device.
  AVCaptureDevice *cameraDevice = [self getCaptureDevice:devicePosition];
  
  // Create camera input and attach to capture session.
  NSError *error;
  AVCaptureInput *input = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
  if (!error) {
    [session addInput:input];
  } else {
    NSLog(@"Unable to attach camera to input: %@", error.localizedDescription);
  }
  
  [session commitConfiguration];
}

-(void)takePhoto:(CGFloat)quality resolver:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject
{
  NSNotificationCenter __weak *center = [NSNotificationCenter defaultCenter];
  id __block token = [center addObserverForName:@"photoReady" object:nil queue:nil usingBlock:^(NSNotification *note){
    [center removeObserver:token]; // One-time notification
    NSData *data = [note.userInfo valueForKey:@"imageData"];
    if (!data) {
      reject(RCTErrorUnspecified, @"Unable to create photo", nil);
      
      return;
    }
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithData:data], quality);
    NSLog(@"Size %f", (float)imageData.length / 1024.0f / 1024.0f);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = paths[0];
    NSString *imageName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
    NSString *fullPath = [cachesDir stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:YES];
    
    resolve(fullPath);
  }];
  
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecJPEG}];
  [stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
  [super willMoveToSuperview:newSuperview];
  session = [AVCaptureSession new];
  session.sessionPreset = AVCaptureSessionPresetPhoto;
  
  AVCaptureDevice *cameraDevice = [self getCaptureDevice:AVCaptureDevicePositionBack];
  
  if (!cameraDevice) {
    NSLog(@"Unable to access camera device");
    return;
  }
  
  NSError *error;
  AVCaptureInput *input = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
  if (!error) {
    stillImageOutput = [AVCapturePhotoOutput new];
    if ([session canAddInput:input] && [session canAddOutput:stillImageOutput]) {
      [session addInput:input];
      [session addOutput:stillImageOutput];
      [self setupLivePreview];
    }
  } else {
    NSLog(@"Unable to attach camera to input: %@", error.localizedDescription);
  }
}

- (void) setupLivePreview
{
  videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
  if (videoPreviewLayer) {
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // Should be handled depending on actual device orientation.
    videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.layer addSublayer:videoPreviewLayer];
    
    // Dispatching async
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
      [session startRunning];
      dispatch_async(dispatch_get_main_queue(), ^{
        //        videoPreviewLayer.frame = [UIScreen mainScreen].bounds;
        videoPreviewLayer.frame = self.bounds;
      });
    });
  }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
  if (!photoSampleBuffer) {
    return;
  }
  
  NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
  NSDictionary *userInfo = @{
                             @"imageData": imageData
                             };
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReady" object:nil userInfo:userInfo];
}

- (void)removeFromSuperview
{
  [super removeFromSuperview];
  [session stopRunning];
}

@end
