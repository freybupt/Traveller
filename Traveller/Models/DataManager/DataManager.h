//
//  DataManager.h
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
#import "Location.h"
#import "Trip.h"
#import "Flight.h"
#import "Itinerary.h"
#import "DSLCalendarRange.h"

extern NSString * const DataManagerOperationDidDeleteEventNotification;

@interface DataManager : NSObject
+ (id)sharedInstance;

/* Store coordinator */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/* Bridged NSManagedObjectContext */
- (void)registerBridgedMoc:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext *)bridgedMoc;

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
- (Event *)newEventWithContext:(NSManagedObjectContext *)moc;
- (Event *)getEventWithEventIdentifier:(NSString *)eventIdentifier
                               context:(NSManagedObjectContext *)moc;
- (NSArray *)getEventWithSelected:(BOOL)isSelected
                          context:(NSManagedObjectContext *)moc;
- (BOOL)addEventWithEKEvent:(EKEvent *)ekEvent
                    context:(NSManagedObjectContext *)moc;
- (BOOL)updateEventWithEKEvent:(EKEvent *)ekEvent
                       context:(NSManagedObjectContext *)moc;
- (BOOL)saveEvent:(Event *)event
          context:(NSManagedObjectContext *)moc;
- (BOOL)deleteEvent:(Event *)event
            context:(NSManagedObjectContext *)moc;

/* Flight */
- (Flight *)newFlightWithContext:(NSManagedObjectContext *)moc;
- (void)setFlight:(Flight *)flight withDictionary:(NSDictionary *)dictionary;
- (BOOL)saveFlight:(Flight *)flight
             context:(NSManagedObjectContext *)moc;
- (BOOL)deleteFlight:(Flight *)flight
            context:(NSManagedObjectContext *)moc;
- (Flight *)getFlightWithFlightIdentifier:(NSString *)flightIdentifier
                                  context:(NSManagedObjectContext *)moc;
/* Trip */
- (NSArray *)getTripWithUserid:(NSNumber *)userid
                       context:(NSManagedObjectContext *)moc;
- (Trip *)getActiveTripByDate:(NSDate *)date
                       userid:(NSNumber *)userid
                      context:(NSManagedObjectContext *)moc;
- (NSArray *)getActiveTripByDateRange:(DSLCalendarRange *)dateRange
                               userid:(NSNumber *)userid
                              context:(NSManagedObjectContext *)moc;
- (BOOL)saveTrip:(Trip *)trip
         context:(NSManagedObjectContext *)moc;
- (BOOL)deleteTrip:(Trip *)trip
           context:(NSManagedObjectContext *)moc;
- (Trip *)newTripWithContext:(NSManagedObjectContext *)moc;

/* Location */
- (Location *)newLocationWithContext:(NSManagedObjectContext *)moc;
- (void)setLocation:(Location *)location withDictionary:(NSDictionary *)dictionary;
- (BOOL)saveLocation:(Location *)location
             context:(NSManagedObjectContext *)moc;

/* Itinerary */
- (NSArray *)getItineraryWithUserid:(NSNumber *)userid
                            context:(NSManagedObjectContext *)moc;
- (Itinerary *)newItineraryWithContext:(NSManagedObjectContext *)moc;
- (BOOL)saveItinerary:(Itinerary *)itinerary
              context:(NSManagedObjectContext *)moc;
- (BOOL)deleteItineray:(Itinerary *)itineray
               context:(NSManagedObjectContext *)moc;
@end
