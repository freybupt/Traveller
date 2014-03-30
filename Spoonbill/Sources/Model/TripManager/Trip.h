//
//  Trip.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSData * defaultColor;
@property (nonatomic, retain) NSString * departureCity;
@property (nonatomic, retain) NSString * destinationCity;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isRoundTrip;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *toEvent;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)insertObject:(Event *)value inToEventAtIndex:(NSUInteger)idx;
- (void)removeObjectFromToEventAtIndex:(NSUInteger)idx;
- (void)insertToEvent:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeToEventAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInToEventAtIndex:(NSUInteger)idx withObject:(Event *)value;
- (void)replaceToEventAtIndexes:(NSIndexSet *)indexes withToEvent:(NSArray *)values;
- (void)addToEventObject:(Event *)value;
- (void)removeToEventObject:(Event *)value;
- (void)addToEvent:(NSOrderedSet *)values;
- (void)removeToEvent:(NSOrderedSet *)values;
@end
