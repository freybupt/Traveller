//
//  Event.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-31.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Trip;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSOrderedSet *toTrip;
@property (nonatomic, retain) City *toCity;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)insertObject:(Trip *)value inToTripAtIndex:(NSUInteger)idx;
- (void)removeObjectFromToTripAtIndex:(NSUInteger)idx;
- (void)insertToTrip:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeToTripAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInToTripAtIndex:(NSUInteger)idx withObject:(Trip *)value;
- (void)replaceToTripAtIndexes:(NSIndexSet *)indexes withToTrip:(NSArray *)values;
- (void)addToTripObject:(Trip *)value;
- (void)removeToTripObject:(Trip *)value;
- (void)addToTrip:(NSOrderedSet *)values;
- (void)removeToTrip:(NSOrderedSet *)values;
@end
