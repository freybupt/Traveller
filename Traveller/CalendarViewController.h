//
//  ViewController.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UIView *planTripView;
@property (nonatomic, weak) IBOutlet UIView *mapView;
@property (nonatomic, weak) IBOutlet UIView *confirmTripView;
@property (nonatomic, weak) IBOutlet UIButton *generateItineraryButton;

//Plan/Book Switch
@property (nonatomic, weak) IBOutlet UIView *tabView;
@property (nonatomic, weak) IBOutlet UIButton *planTripSwitch;
@property (nonatomic, weak) IBOutlet UIButton *mapSwitch;
@property (nonatomic, weak) IBOutlet UIButton *confirmTripSwitch;

//my schedule table
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UITableView *scheduleTableView;
@property (nonatomic, weak) IBOutlet UIButton *expandButton;

//Destination View
@property (nonatomic, weak) IBOutlet UIView *destinationPanel;
@property (nonatomic, weak) IBOutlet UITextField *destinationTextField;
@property (nonatomic, weak) IBOutlet UITextField *departureLocationTextField;
@property (nonatomic, weak) IBOutlet UIButton *removeTripButton;
@property (nonatomic, weak) IBOutlet UIButton *confirmDestinationButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelEditDestinationButton;



- (IBAction)addEvent:(id)sender;
- (IBAction)adjustScheduleView:(id)sender;

- (IBAction)showDestinationPanel:(id)sender;
- (IBAction)hideDestinationPanel:(id)sender;


- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event;

- (IBAction)switchDidTapped:(id)sender;

@end
