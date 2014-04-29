//
//  Car.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rental;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * mark;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * reg_no;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * information;
@property (nonatomic, retain) NSString * restriction;
@property (nonatomic, retain) Rental *toRental;

@end
