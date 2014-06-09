//
//  Amenity.h
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-09.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Amenity : NSManagedObject

//TODO: create something to assign the flights
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Event * toEvent;

@end
