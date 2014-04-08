//
//  PLPlanTripCalendarViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripViewController.h"
#import "PLPlanTripCalendarHeaderFooterView.h"
#import "DSLCalendarView.h"

#define SECTIONHEADER_FOR_TOOLCONTROL_POINTER 1

@interface PLPlanTripCalendarViewController : PLPlanTripViewController<DSLCalendarViewDelegate>
@property (nonatomic, weak) IBOutlet DSLCalendarView *calendarView;
@end
