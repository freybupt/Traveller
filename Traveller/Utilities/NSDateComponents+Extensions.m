//
//  NSDateComponents+Extensions.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "NSDateComponents+Extensions.h"

@implementation NSDateComponents (Extensions)
- (NSDate *)dateWithGMTZoneCalendar
{
    if (!self) {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [calendar dateFromComponents:self];
}
@end