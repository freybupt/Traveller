//
//  City.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * latitudeRef;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * longitudeRef;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * cityCode;

@end
