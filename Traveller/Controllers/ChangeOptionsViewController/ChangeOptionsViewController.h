//
//  ChangeOptionsViewController.h
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarMapViewController.h"
@class ChangeOptionsViewController;
@protocol ChangeOptionsViewControllerDelegate <NSObject>

- (void)addItemViewController:(ChangeOptionsViewController *)controller didFinishEnteringItem:(NSDictionary*)selectedTrip;

@end

@interface ChangeOptionsViewController : CalendarMapViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) Trip* trip;
@property (nonatomic, weak) IBOutlet UISegmentedControl *criteriaSegmentedControl;
@property (nonatomic, weak) id <ChangeOptionsViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
