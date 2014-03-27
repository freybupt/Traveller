//
//  LocationManager.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationManager
+ (id)sharedInstance
{
    static LocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
	if ((self = [super init]))
	{
        NSLog(@"Initializing Location Manager");
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	return self;
}

#pragma mark - CLLocationManager
- (void)startUpdatingLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocation delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        [self getPlacemarkWithLocation:location
                                 block:^(CLPlacemark *placemark, NSError *error) {
                                     if (!error) {
                                         NSLog(@"%@", placemark.addressDictionary);
                                         NSLog(@"Latitude: %f", placemark.location.coordinate.latitude);
                                         NSLog(@"LatitudeRef: %@", placemark.location.coordinate.latitude > 0 ? NSLocalizedString(@"North", nil) : NSLocalizedString(@"South", nil));
                                         NSLog(@"Longitude: %f", placemark.location.coordinate.longitude);
                                         NSLog(@"LongitudeRef: %@", placemark.location.coordinate.longitude > 0 ? NSLocalizedString(@"East", nil) : NSLocalizedString(@"West", nil));
                                     }
        }];
        
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    NSLog(@"CLLocation Error: %@", [error localizedDescription]);
}

#pragma mark - CLGeocoder
- (CLGeocoder *)getPlacemarkWithLocation:(CLLocation *)location
                           block:(void (^)(CLPlacemark *placemark, NSError *error))block
{
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (!error) {
                           if (block) {
                               block([placemarks lastObject], nil);
                           }
                       } else {
                           if (block) {
                               block(nil, error);
                           }
                       }
                   }];
    
    return geoCoder;
}

- (CLGeocoder *)getPlacemarkWithAddress:(NSString *)string
                                  block:(void (^)(CLPlacemark *placemark, NSError *error))block
{
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder geocodeAddressString:string
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error) {
                         if (block) {
                             block([placemarks lastObject], nil);
                         }
                     } else {
                         if (block) {
                             block(nil, error);
                         }
                     }
    }];
    return geoCoder;
}
@end
