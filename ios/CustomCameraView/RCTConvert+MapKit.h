//
//  RCTConvert+MapKit.h
//  CustomCameraView
//
//  Created by Philip Klochkov on 10/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

@interface RCTConvert (MapKit)
+ (MKCoordinateSpan)MKCoordinateSpan:(id)json;
+ (MKCoordinateRegion)MKCoordinateRegion:(id)json;
@end
