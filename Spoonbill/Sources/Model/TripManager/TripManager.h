//
//  TripManager.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <EventKit/EventKit.h>
#import "City.h"
#import "Event.h"

@interface TripManager : NSObject
+ (id)sharedInstance;

/* Store coordinator */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/* City */
- (City *)getCityWithCityName:(NSString *)cityName
                      context:(NSManagedObjectContext *)moc;
- (BOOL)addCityWithDictionary:(NSDictionary *)dictionary
                      context:(NSManagedObjectContext *)moc;
- (BOOL)updateCity:(City *)city
           context:(NSManagedObjectContext *)moc;
- (BOOL)deleteCity:(City *)city
           context:(NSManagedObjectContext *)moc;

/* Event */
- (Event *)getEventWithEventIdentifier:(NSString *)eventIdentifier
                               context:(NSManagedObjectContext *)moc;
- (BOOL)addEventWithEKEvent:(EKEvent *)ekEvent
                    context:(NSManagedObjectContext *)moc;
- (BOOL)updateEvent:(Event *)event
            context:(NSManagedObjectContext *)moc;
- (BOOL)deleteEvent:(Event *)event
            context:(NSManagedObjectContext *)moc;
@end
