//
//  TripManager.h
//  Traveller
//
//  Created by Shirley on 2/26/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "Trip.h"

static NSString *const kTripChangeNotification = @"tripChangeNotification";
static NSString *const kTripListKey = @"allTripSaved";

typedef NS_ENUM(NSInteger, TripStage){
    TripStageSelectEvent,
    TripStagePlanTrip,
    TripStageBookTrip,
    TripStageTrackTrip
};

typedef NS_ENUM(NSInteger, EventType){
    EventTypeDefault = 0,
    EventTypeFlight,
    EventTypeHotel,
    EventTypeRental
};

@interface TripManager : NSObject
@property (nonatomic, assign) TripStage tripStage;
@property (nonatomic, strong) NSMutableDictionary *tripColorDictionary;
@property (nonatomic, strong) NSMutableDictionary *tripCityCodeDictionary;

+ (id)sharedManager;
@end