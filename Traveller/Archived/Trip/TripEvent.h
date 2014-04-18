//
//  TripEvent.h
//  Traveller
//
//  Created by Shirley on 2/26/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


typedef enum{
    kEventTypeMySchedule = 1,
    kEventTypeFlightBooking,
    kEventTypeHotelBooking,
    kEventTypeRentalCarBooking,
    kEventTypeOther
}TripEventType;

@interface TripEvent : NSObject

@property (nonatomic, strong) EKEvent *eventObj; //inclue time and location
@property (nonatomic, assign) TripEventType eventType;

@property (nonatomic, assign) BOOL isBooked;
@property (nonatomic, assign) CGFloat bookingPrice;
@end
