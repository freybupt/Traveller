//
//  PlanTripViewController.h
//  Traveller
//
//  Created by WEI-JEN TU on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarMapViewController.h"
#import "ChangeOptionsViewController.h"

@interface PlanTripViewController : CalendarMapViewController <ChangeOptionsViewControllerDelegate>
@property (nonatomic) BOOL wasChanged;


@end
