//
//  ViewController.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "EventViewController.h"
#import "DestinationPanelView.h"

@interface CalendarViewController : EventViewController


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
@property (nonatomic, weak) IBOutlet UIButton *expandButton;

//Destination Panel View
@property (nonatomic, weak) IBOutlet DestinationPanelView *destinationPanelView;

- (IBAction)adjustScheduleView:(id)sender;
- (IBAction)editMySchedule:(id)sender;

- (IBAction)showDestinationPanel:(id)sender;
- (IBAction)hideDestinationPanel:(id)sender;


- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event;

- (IBAction)switchDidTapped:(id)sender;

@end
