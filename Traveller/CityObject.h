//
//  CityObject.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityObject : NSObject

@property (nonatomic, strong) NSString *cityFullName;
@property (nonatomic, strong) NSString *cityShortName;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) NSString *countryName;
@end
