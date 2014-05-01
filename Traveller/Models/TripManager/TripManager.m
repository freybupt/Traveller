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

@end

@implementation TripManager

+ (id)sharedManager
{
    static TripManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
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
@end


