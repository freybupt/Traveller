//
//  TripManager.m
//  Traveller
//
//  Created by Shirley on 2/26/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "TripManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface TripManager ()

@property (nonatomic, strong) NSMutableArray *activeTripList;
@property (nonatomic, strong) NSArray *pastTripList;

@end

@implementation TripManager

+ (id)sharedManager
{
    static TripManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.activeTripList = [[NSMutableArray alloc] init];
        
        //TODO: retrieve trips from db. add to activeTripList

//        NSMutableArray *allTripsKeys = [[NSUserDefaults standardUserDefaults] objectForKey:kTripListKey];
//        for (NSString *tripKey in allTripsKeys) {
//            Trip *savedTrip = [manager loadCustomObjectWithKey:tripKey];
//            [manager.activeTripList addObject:savedTrip];
//        }
    });
    
    return manager;
}


- (void)setTripStage:(TripStage)tripStage
{
    [[NSUserDefaults standardUserDefaults] setInteger:tripStage forKey:@"TripStage"];
}

- (TripStage)tripStage
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"TripStage"];
}


- (void)addTripToActiveList:(Trip *)currentTrip
{
    //insert the trip to activeTripList by start time order
    if (self.activeTripList == nil) {
        self.activeTripList = [[NSMutableArray alloc] init];
        [self.activeTripList addObject:currentTrip];
    }
    else{
        BOOL tripAdded = NO;
        for (NSUInteger index = 0; index < [self.activeTripList count]; index++) {
            Trip *oneTrip = [self.activeTripList objectAtIndex:index];
            if ([oneTrip.startDate compare:currentTrip.startDate] != NSOrderedAscending) {
                [self.activeTripList insertObject:currentTrip atIndex:index];
                tripAdded = YES;
                break;
            }
        }
        if (!tripAdded) {
            [self.activeTripList addObject:currentTrip];
        }
        
        //TODO: if a trip range is covering current ones, remove old trip?
        
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tripKey = [self getTripKey:currentTrip];
        [self saveCustomObject:currentTrip key:tripKey];
        
        //update trip key list
        NSMutableArray *savedtripKeys = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTripListKey]];
        if (savedtripKeys == nil) {
            savedtripKeys = [[NSMutableArray alloc] init];
        }
        [savedtripKeys addObject:tripKey];
        [[NSUserDefaults standardUserDefaults] setObject:savedtripKeys forKey:kTripListKey];
    });
    
    //send notification for trip updated
    [[NSNotificationCenter defaultCenter] postNotificationName:kTripChangeNotification object:self];
}

- (void)modifyTrip:(Trip *)oldTrip toNewTrip:(Trip *)updatedTrip
{
    NSMutableArray *tripListCopy = [NSMutableArray arrayWithArray:self.activeTripList];
    for (NSUInteger index = 0; index < [self.activeTripList count]; index++) {
        Trip *oneTrip = [self.activeTripList objectAtIndex:index];
        if ([oneTrip isEqual:oldTrip]) {
            [tripListCopy removeObject:oldTrip];
            [tripListCopy insertObject:updatedTrip atIndex:index];
            NSString *oldTripKey = [self getTripKey:oldTrip];
            [self saveCustomObject:nil key:oldTripKey];
            NSString *updatedTripKey = [self getTripKey:updatedTrip];
            [self saveCustomObject:updatedTrip key:updatedTripKey];
            //update trip key list
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSMutableArray *savedtripKeys = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTripListKey]];
                [savedtripKeys removeObject:oldTripKey];
                [savedtripKeys addObject:updatedTripKey];
                [[NSUserDefaults standardUserDefaults] setObject:savedtripKeys forKey:kTripListKey];
            });
            
            break;
        }
    }
    self.activeTripList = [NSMutableArray arrayWithArray:tripListCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTripChangeNotification object:self];
}

- (void)deleteTrip:(Trip *)trip
{
    NSMutableArray *tripListCopy = [NSMutableArray arrayWithArray:self.activeTripList];
    for (NSUInteger index = 0; index < [self.activeTripList count]; index++) {
        Trip *oneTrip = [self.activeTripList objectAtIndex:index];
        if ([oneTrip isEqual:trip]) {
            [tripListCopy removeObject:trip];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSString *oldTripKey = [self getTripKey:trip];
                [self saveCustomObject:nil key:oldTripKey];
                NSMutableArray *savedtripKeys = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTripListKey]];
                [savedtripKeys removeObject:oldTripKey];
                [[NSUserDefaults standardUserDefaults] setObject:savedtripKeys forKey:kTripListKey];
            });
            
            break;
        }
    }
    self.activeTripList = [NSMutableArray arrayWithArray:tripListCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTripChangeNotification object:self];
}


- (Trip *)findActiveTripByDate:(NSDate *)date
{
    for (Trip *trip in self.activeTripList) {
        //date within trip range
        if ([trip.startDate compare:date] != NSOrderedDescending &&
            [trip.startDate compare:date] != NSOrderedAscending) {
            return trip;
        }
    }
    return nil;
}



- (NSArray *)getUsedTripColors
{
    NSMutableArray *allColors = [[NSMutableArray alloc] init];
    for (Trip *eachTrip in self.activeTripList) {
        [allColors addObject:eachTrip.defaultColor];
    }
    
    return [NSArray arrayWithArray:allColors];
}

- (NSInteger)countActiveTrips
{
    return [self.activeTripList count];
}


#pragma mark - Save Trips

- (void)saveCustomObject:(Trip *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (Trip *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    Trip *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

- (NSString *)getTripKey:(Trip *)trip
{

    //create unique key for this trip
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@", trip.toCityDestinationCity.cityName, [trip.startDate description], [trip.endDate description], trip.isRoundTrip?@"roundTrip":@"oneWay"];
    return key;
}
@end


