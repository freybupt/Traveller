//
//  LocationManager.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define MAX_LENGTH_OF_CITYCODE 2
#define CURRENT_CITY_KEY @"CurrentCityKey"

@interface LocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong) NSDictionary *cityDictionary;

+ (id)sharedInstance;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (CLGeocoder *)getPlacemarkWithLocation:(CLLocation *)location
                                   block:(void (^)(CLPlacemark *placemark, NSError *error))block;
- (CLGeocoder *)getPlacemarkWithAddress:(NSString *)string
                                  block:(void (^)(CLPlacemark *placemark, NSError *error))block;
@end