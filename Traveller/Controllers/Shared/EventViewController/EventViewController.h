//
//  EventViewController.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-18.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CDTableViewController.h"
#import "MyScheduleTableCell.h"

@interface EventViewController : CDTableViewController<EKEventEditViewDelegate, EKEventViewDelegate, UINavigationControllerDelegate>

- (IBAction)addEventButtonTapAction:(id)sender;
- (IBAction)saveEventButtonTapAction:(EKEvent *)event;
- (IBAction)editEventButtonTapAction:(Event *)event;
- (IBAction)updateEventButtonTapAction:(EKEvent *)event;
- (IBAction)deleteEventButtonTapAction:(Event *)event;

@end
