//
//  City.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "City.h"

@implementation City

- (id)initWithCityName: (NSString *)cityName
{
    if (self = [super init]) {
        //TODO: reverse geo coding to find city by name and fill geo details
        if ([cityName length] > 0) {
            cityName = [NSString stringWithFormat:@"%@   ", cityName];
            self.cityFullName = cityName;
            self.cityShortName = [[cityName uppercaseString] substringToIndex:2];
        }
    }
    return self;
}
@end
