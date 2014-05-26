//
//  Event.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Location, Trip;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) City *toCity;
@property (nonatomic, retain) Location *toLocation;
@property (nonatomic, retain) NSSet *toTrip;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addToTripObject:(Trip *)value;
- (void)removeToTripObject:(Trip *)value;
- (void)addToTrip:(NSSet *)values;
- (void)removeToTrip:(NSSet *)values;

@end
