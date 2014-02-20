//
//  ViewController.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UITableView *scheduleTableView;

- (IBAction)addEvent:(id)sender;
- (IBAction)dismissDestinationPopup:(id)sender;
- (IBAction)showDestinationPopup:(id)sender;

@end
