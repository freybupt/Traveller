//
//  Itinerary.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Itinerary : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *toTrip;
@end

@interface Itinerary (CoreDataGeneratedAccessors)

- (void)addToTripObject:(Trip *)value;
- (void)removeToTripObject:(Trip *)value;
- (void)addToTrip:(NSSet *)values;
- (void)removeToTrip:(NSSet *)values;

@end
