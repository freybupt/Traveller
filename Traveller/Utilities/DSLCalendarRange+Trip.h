//
//  DSLCalendarRange+Trip.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DSLCalendarRange.h"

@interface DSLCalendarRange (Trip)
- (DSLCalendarRange *)joinedCalendarRangeWithTrip:(Trip *)trip;
@end
