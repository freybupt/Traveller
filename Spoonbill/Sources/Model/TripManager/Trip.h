//
//  Trip.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Event, Rental;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSData * defaultColor;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isRoundTrip;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) City *toCityDepartureCity;
@property (nonatomic, retain) City *toCityDestinationCity;
@property (nonatomic, retain) NSSet *toEvent;
@property (nonatomic, retain) NSSet *toRental;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addToEventObject:(Event *)value;
- (void)removeToEventObject:(Event *)value;
- (void)addToEvent:(NSSet *)values;
- (void)removeToEvent:(NSSet *)values;

- (void)addToRentalObject:(Rental *)value;
- (void)removeToRentalObject:(Rental *)value;
- (void)addToRental:(NSSet *)values;
- (void)removeToRental:(NSSet *)values;

@end
