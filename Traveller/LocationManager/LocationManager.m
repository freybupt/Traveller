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
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
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
        
        _managedObjectContext = [self newManagedObjectContext];
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
                                         _cityDictionary = [self cityDictionaryWithPlacemark:placemark];
                                         [[DataManager sharedInstance] addCityWithDictionary:_cityDictionary context:_managedObjectContext];
                                         [[NSUserDefaults standardUserDefaults] setObject:_cityDictionary[@"City"] forKey:CURRENT_CITY_KEY];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - Location
- (CLLocation *)currentLocation
{
    return _locationManager.location;
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

#pragma mark - Configuration
- (NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext new];
    managedObjectContext.undoManager = nil;
    managedObjectContext.persistentStoreCoordinator = [[DataManager sharedInstance] persistentStoreCoordinator];
    
    return managedObjectContext;
}

#pragma mark - Helper
- (NSDictionary *)cityDictionaryWithPlacemark:(CLPlacemark *)placemark
{
    NSString *city = placemark.addressDictionary[@"City"];
    NSString *cityCode = [placemark.addressDictionary[@"City"] length] > MAX_LENGTH_OF_CITYCODE ? [[placemark.addressDictionary[@"City"] uppercaseString] substringToIndex:MAX_LENGTH_OF_CITYCODE] : placemark.addressDictionary[@"City"];
    NSString *country = placemark.addressDictionary[@"Country"];
    NSString *countryCode = placemark.addressDictionary[@"CountryCode"];
    NSNumber *latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
    NSString *latitudeRef = placemark.location.coordinate.latitude > 0 ? NSLocalizedString(@"North", nil) : NSLocalizedString(@"South", nil);
    NSNumber *longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
    NSString *longitudeRef = placemark.location.coordinate.longitude > 0 ? NSLocalizedString(@"East", nil) : NSLocalizedString(@"West", nil);
    NSNumber *uid = [MockManager userid];
    
    return @{ @"City" : city,
              @"CityCode" : cityCode,
              @"Country" : country,
              @"CountryCode" : countryCode,
              @"Latitude" : latitude,
              @"LatitudeRef" : latitudeRef,
              @"Longitude" : longitude,
              @"LongitudeRef" : longitudeRef,
              @"id" : uid};
}
@end
