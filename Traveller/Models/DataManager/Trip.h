//
//  Trip.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-02.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Event;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSData * defaultColor;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isEditing;
@property (nonatomic, retain) NSNumber * isRoundTrip;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) City *toCityDepartureCity;
@property (nonatomic, retain) City *toCityDestinationCity;
@property (nonatomic, retain) Event *toEvent;

@end
