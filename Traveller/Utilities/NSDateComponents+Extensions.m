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
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    return [calendar dateFromComponents:self];
}

- (NSInteger)uniqueDateNumber
{
    return self.year * 10000 + self.month * 100 + self.day;
}
@end
