//
//  Event.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * uid;

@end
