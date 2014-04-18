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

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.cityFullName forKey:@"cityFullName"];
    [encoder encodeObject:self.cityShortName forKey:@"cityShortName"];
    [encoder encodeObject:self.countryName forKey:@"countryName"];
    [encoder encodeObject:self.location forKey:@"location"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.cityFullName = [decoder decodeObjectForKey:@"cityFullName"];
        self.cityShortName = [decoder decodeObjectForKey:@"cityShortName"];
        self.countryName = [decoder decodeObjectForKey:@"countryName"];
        self.location = [decoder decodeObjectForKey:@"location"];
    }
    return self;
}


@end
