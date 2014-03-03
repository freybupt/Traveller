//
//  TripManager.h
//  Traveller
//
//  Created by Shirley on 2/26/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

static NSString *const kTripChangeNotification = @"tripChangeNotification";
static NSString *const kTripListKey = @"allTripSaved";


@interface TripManager : NSObject

+ (id)sharedManager;
- (void)addTripToActiveList:(Trip *)trip;
- (void)modifyTrip:(Trip *)oldTrip toNewTrip:(Trip *)updatedTrip;
- (void)deleteTrip:(Trip *)trip;

- (Trip *)findActiveTripByDate:(NSDate *)date;
- (NSArray *)getUsedTripColors;
- (NSInteger)countActiveTrips;

@end
