//
//  Rental.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Branch, Car, Trip;

@interface Rental : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isRoundTrip;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Branch *toBranchPickupBranch;
@property (nonatomic, retain) Branch *toBranchDropoffBranch;
@property (nonatomic, retain) Car *toCar;
@property (nonatomic, retain) NSSet *toTrip;
@end

@interface Rental (CoreDataGeneratedAccessors)

- (void)addToTripObject:(Trip *)value;
- (void)removeToTripObject:(Trip *)value;
- (void)addToTrip:(NSSet *)values;
- (void)removeToTrip:(NSSet *)values;

@end
