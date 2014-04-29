//
//  Hotel.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City;

@interface Hotel : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * latitudeRef;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * longitudeRef;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) City *toCity;

@end
