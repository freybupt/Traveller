//
//  NSDate+Extensions.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)
- (NSDate *)dateAtMidnight
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *dateComponents = [calendar components:(NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                   fromDate:self];
    return [self dateByAddingTimeInterval:- (60 * 60 * dateComponents.hour + 60 * dateComponents.minute + dateComponents.second)];
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
@end
