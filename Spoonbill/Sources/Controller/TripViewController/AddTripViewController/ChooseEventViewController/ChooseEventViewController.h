//
//  ChooseEventViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "EventViewController.h"

extern NSString * const TripOperationDidUpdateTripEventsNotification;

@interface ChooseEventViewController : EventViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                 trip:(Trip *)trip;
@end
