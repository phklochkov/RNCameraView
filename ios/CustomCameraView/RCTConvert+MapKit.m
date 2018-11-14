//
//  RCTConvert+MapKit.m
//  CustomCameraView
//
//  Created by Philip Klochkov on 10/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <React/RCTConvert.h>
#import <React/RCTConvert+CoreLocation.h>

@implementation RCTConvert(MapKit)

+(MKCoordinateSpan)MKCoordinateSpan:(id)json
{
  json = [self NSDictionary:json];
  return (MKCoordinateSpan){
    [self CLLocationDegrees:json[@"latitudeDelta"]],
    [self CLLocationDistance:json[@"longitudeDelta"]]
  };
}

+(MKCoordinateRegion)MKCoordinateRegion:(id)json
{
  json = [self NSDictionary:json];
  return (MKCoordinateRegion){
    [self CLLocationCoordinate2D:json],
    [self MKCoordinateSpan:json]
  };
}

@end
