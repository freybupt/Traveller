//
//  NSDate+Extensions.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)
- (NSDate *)dateAtMidnight;
- (NSDate *)dateAtFourPM;
- (NSDate *)dateOnFirstDay;
- (NSDate *)dateBeforeOneDay;
- (NSDate *)dateAfterOneDay;
- (NSString *)hourTime;
- (NSString *)monthDayTime;
- (NSString *)translatedTime;
- (NSString *)relativeTime;
- (NSDateComponents *)dateComponents;
- (BOOL)withinSameDayWith:(NSDate *)date;
@end
