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
#import "Trip.h"
#import "Car.h"

extern NSString * const TripManagerOperationDidDeleteEventNotification;

@interface TripManager : NSObject
+ (id)sharedInstance;

/* Store coordinator */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/* City */
- (NSArray *)getCityWithUserid:(NSNumber *)userid
                       context:(NSManagedObjectContext *)moc;
- (City *)getCityWithCityName:(NSString *)cityName
                      context:(NSManagedObjectContext *)moc;
- (BOOL)addCityWithDictionary:(NSDictionary *)dictionary
                      context:(NSManagedObjectContext *)moc;
- (BOOL)saveCity:(City *)city
         context:(NSManagedObjectContext *)moc;
- (BOOL)deleteCity:(City *)city
           context:(NSManagedObjectContext *)moc;

/* Event */
- (Event *)getEventWithEventIdentifier:(NSString *)eventIdentifier
                               context:(NSManagedObjectContext *)moc;
- (BOOL)addEventWithEKEvent:(EKEvent *)ekEvent
                    context:(NSManagedObjectContext *)moc;
- (BOOL)updateEventWithEKEvent:(EKEvent *)ekEvent
                       context:(NSManagedObjectContext *)moc;
- (BOOL)saveEvent:(Event *)event
          context:(NSManagedObjectContext *)moc;
- (BOOL)deleteEvent:(Event *)event
            context:(NSManagedObjectContext *)moc;

/* Trip */
- (BOOL)saveTrip:(Trip *)trip
         context:(NSManagedObjectContext *)moc;
- (BOOL)deleteTrip:(Trip *)trip
           context:(NSManagedObjectContext *)moc;

/* Car */
- (Car *)getCarWithRegNo:(NSString *)regNo
                 context:(NSManagedObjectContext *)moc;
- (BOOL)addCarWithDictionary:(NSDictionary *)dictionary
                     context:(NSManagedObjectContext *)moc;
- (BOOL)saveCar:(Car *)car
        context:(NSManagedObjectContext *)moc;
- (BOOL)deleteCar:(Car *)car
          context:(NSManagedObjectContext *)moc;

@end
