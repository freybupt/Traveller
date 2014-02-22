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

//Destination View
@property (nonatomic, weak) IBOutlet UIView *destinationPanel;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *confirmButton;

@property (nonatomic, weak) IBOutlet UIView *tabView;
@property (nonatomic, weak) IBOutlet UITextField *destinationTextField;
@property (nonatomic, weak) IBOutlet UITextField *departureLocationTextField;

- (IBAction)addEvent:(id)sender;
- (IBAction)dismissDestinationPopup:(id)sender;
- (IBAction)showDestinationPopup:(id)sender;

- (IBAction)showDestinationPanel:(id)sender;
- (IBAction)hideDestinationPanel:(id)sender;

@end
