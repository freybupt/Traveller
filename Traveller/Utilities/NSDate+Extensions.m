//
//  NSDate+Extensions.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "NSDate+Extensions.h"

#define ONE_DAY 60 * 60 * 24

@implementation NSDate (Extensions)

-(NSDate *)localDate
{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:self];
    
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

-(NSDate *)GMTDate
{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[timeZone secondsFromGMTForDate:self];
    
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

- (NSDate *)dateAtMidnight
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *dateComponents = [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit)
                                                   fromDate:self];
    return [self dateByAddingTimeInterval:- (60 * 60 * dateComponents.hour + 60 * dateComponents.minute + dateComponents.second)];
}

- (NSDate *)dateAtFourPM
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *dateComponents = [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit)
                                                   fromDate:self];
    return [self dateByAddingTimeInterval:- (60 * 60 * (dateComponents.hour - 16) + 60 * dateComponents.minute + dateComponents.second)];
}

- (NSDate *)dateOnFirstDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *dateComponents = [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit)
                                                   fromDate:self];
    return [self dateByAddingTimeInterval:- (60 * 60 * dateComponents.hour + 60 * dateComponents.minute + dateComponents.second) - ONE_DAY * (dateComponents.day - 1)];
}

- (NSDate *)dateBeforeOneDay
{
    return [self dateByAddingTimeInterval:-ONE_DAY];
}

- (NSDate *)dateAfterOneDay
{
    return [self dateByAddingTimeInterval:ONE_DAY];
}

- (NSString *)hourTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
	return [dateFormatter stringFromDate:self];
}

- (NSString *)monthDayTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"MMMM dd"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
	return [dateFormatter stringFromDate:self];
}

- (NSString *)translatedTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"EEEE MMMM dd HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
	return [dateFormatter stringFromDate:self];
}

- (NSString *)relativeTime
{
	NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    // Get the system calendar
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	
	// Get conversion to months, days, hours, minutes
	unsigned int unitFlags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
	NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:self  toDate:currentDate  options:0];
    
    if ([conversionInfo year] > 0) {
		return ([conversionInfo year] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo year]], NSLocalizedString(@"year ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo year]], NSLocalizedString(@"years ago", @"")];
	} else if ([conversionInfo year] < 0) {
        return ([conversionInfo year] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo year]], NSLocalizedString(@"year later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo year]], NSLocalizedString(@"years later", @"")];
    }
    
    if ([conversionInfo month] > 0) {
		return ([conversionInfo month] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo month]], NSLocalizedString(@"month ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo month]], NSLocalizedString(@"months ago", @"")];
	} else if ([conversionInfo month] < 0) {
        return ([conversionInfo month] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo month]], NSLocalizedString(@"month later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo month]], NSLocalizedString(@"months later", @"")];
    }
	
    if ([conversionInfo week] > 0) {
		return ([conversionInfo week] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo week]], NSLocalizedString(@"week ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo week]], NSLocalizedString(@"weeks ago", @"")];
	} else if ([conversionInfo week] < 0) {
        return ([conversionInfo week] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo week]], NSLocalizedString(@"week later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo week]], NSLocalizedString(@"weeks later", @"")];
    }
    
	if ([conversionInfo day] > 0) {
		return ([conversionInfo day] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo day]], NSLocalizedString(@"day ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo day]], NSLocalizedString(@"days ago", @"")];
	} else if ([conversionInfo day] < 0) {
        return ([conversionInfo day] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo day]], NSLocalizedString(@"day later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo day]], NSLocalizedString(@"days later", @"")];
    }
	
	if ([conversionInfo hour] > 0) {
		return ([conversionInfo hour] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo hour]], NSLocalizedString(@"hour ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo hour]], NSLocalizedString(@"hours ago", @"")];
	} else if ([conversionInfo hour] < 0) {
        return ([conversionInfo hour] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo hour]], NSLocalizedString(@"hour later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo hour]], NSLocalizedString(@"hours later", @"")];
    }
    
    if ([conversionInfo minute] > 0) {
		return ([conversionInfo minute] == 1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo minute]], NSLocalizedString(@"min ago", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:[conversionInfo minute]], NSLocalizedString(@"mins ago", @"")];
	} else if ([conversionInfo minute] < 0) {
        return ([conversionInfo minute] == -1) ? [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo minute]], NSLocalizedString(@"min later", @"")] : [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:-[conversionInfo minute]], NSLocalizedString(@"mins later", @"")];
    }
    
    return NSLocalizedString(@"now", @"");
}

- (NSDateComponents *)dateComponents
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:self];
    [components setCalendar:calendar];
    
    return components;
}

- (BOOL)withinSameDayWith:(NSDate *)date
{
    return ([self dateComponents].day == [date dateComponents].day &&
            [self dateComponents].month == [date dateComponents].month);
}
@end
