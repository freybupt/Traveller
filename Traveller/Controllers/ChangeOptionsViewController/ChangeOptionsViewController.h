//
//  ChangeOptionsViewController.h
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarMapViewController.h"
@interface ChangeOptionsViewController : CalendarMapViewController
@property (nonatomic) Trip* trip;
@property (nonatomic, weak) IBOutlet UISegmentedControl *criteriaSegmentedControl;


@end
