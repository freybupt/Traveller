//
//  City.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface City : NSObject

@property (nonatomic, strong) NSString *cityFullName;
@property (nonatomic, strong) NSString *cityShortName;
@property (nonatomic, assign) NSString *countryName;

@property (nonatomic, strong) CLLocation *location;


- (id)initWithCityName: (NSString *)cityName;
@end
