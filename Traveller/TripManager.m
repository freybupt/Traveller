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
    static TripManager *mamager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mamager = [[self alloc] init];
    });
    
    return mamager;
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
            if ([oneTrip.dateRange.startDay.date compare:currentTrip.dateRange.startDay.date] != NSOrderedAscending) {
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
        if ([trip.dateRange.startDay.date compare:date] != NSOrderedDescending &&
            [trip.dateRange.endDay.date compare:date] != NSOrderedAscending) {
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



@end
