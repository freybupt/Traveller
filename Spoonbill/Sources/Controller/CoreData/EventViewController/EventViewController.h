//
//  EventViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CDTableViewController.h"

@interface EventViewController : CDTableViewController
- (IBAction)addEventButtonTapAction:(id)sender;
- (IBAction)eventDetailButtonTapAction:(Event *)event;
@end
