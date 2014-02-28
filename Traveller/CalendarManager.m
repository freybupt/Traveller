//
//  CalendarManager.m
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarManager.h"
#import "Trip.h"

@interface CalendarManager ()


@end

@implementation CalendarManager

+ (id)sharedManager
{
    static CalendarManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    if (self = [super init]) {
        // Initialize the event store
        self.eventStore = [[EKEventStore alloc] init];
    }
    return self;
}


// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized:
            //post notification of access granted
            [self postNotificationForGrantedAccess:YES];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [self postNotificationForGrantedAccess:NO];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //post notification of access granted
                 [self postNotificationForGrantedAccess:YES];
             });
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 //post notification of access denied
                 [self postNotificationForGrantedAccess:NO];
             });
         }
     }];
}

- (void)postNotificationForGrantedAccess:(BOOL)isGranted
{
    // where you would call a delegate method (e.g. [self.delegate doSomething])
    NSDictionary *accessDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isGranted],@"hasAccess", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGrantCalendarAccessNotification object:self userInfo:accessDict];
}



@end
