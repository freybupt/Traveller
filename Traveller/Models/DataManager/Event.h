//
//  Event.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Trip;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) City *toCity;
@property (nonatomic, retain) NSSet *toTrip;
@property (nonatomic, retain) NSNumber * eventType;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addToTripObject:(Trip *)value;
- (void)removeToTripObject:(Trip *)value;
- (void)addToTrip:(NSSet *)values;
- (void)removeToTrip:(NSSet *)values;

@end
