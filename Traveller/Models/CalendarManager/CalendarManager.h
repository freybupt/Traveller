//
//  CalendarManager.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@class Trip;
static NSString *const kGrantCalendarAccessNotification = @"grantCalendarAccessNotification";

@interface CalendarManager : NSObject
// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;


+ (id)sharedManager;
- (void)checkEventStoreAccessForCalendar;
- (NSArray *)fetchEventsFromStartDate:(NSDate *)startDate
                            toEndDate:(NSDate *)endDate;
@end
