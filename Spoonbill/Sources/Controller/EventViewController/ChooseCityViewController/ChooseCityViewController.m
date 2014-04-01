//
//  ChooseCityViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <EventKitUI/EventKitUI.h>
#import "ChooseCityViewController.h"

@interface ChooseCityViewController ()<EKEventEditViewDelegate>

@end

@implementation ChooseCityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Choose City", nil);
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(backButtonTapAction:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)addEventButtonTapAction:(City *)city
{
    /* Create an eventStore with a location for EKEventEditViewController */
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.location = city.cityName;
    
    EKEventEditViewController *vc = [[EKEventEditViewController alloc] init];
	vc.eventStore = eventStore;
    vc.event = event;
    vc.editViewDelegate = self;
    [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)saveEventButtonTapAction:(EKEvent *)event
{
    if ([[TripManager sharedInstance] getEventWithEventIdentifier:event.eventIdentifier
                                                          context:self.managedObjectContext]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"The event item has been saved before", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([[TripManager sharedInstance] addEventWithEKEvent:event
                                                  context:self.managedObjectContext]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when inserting an event item", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)backButtonTapAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Table view data source & delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    City *city = (City *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status)
    {
        case EKAuthorizationStatusAuthorized:{
            [self addEventButtonTapAction:city];
        }break;
        case EKAuthorizationStatusNotDetermined:{
            [self requestCalendarAccessWithCity:city];
        }break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [self showAccessCalendarsPrompt];
        }break;
    }
}

#pragma mark - Request Calendar Access
- (void)requestCalendarAccessWithCity:(City *)city
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent
                               completion:^(BOOL granted, NSError *error){
                                   if (granted) {
                                       [self addEventButtonTapAction:city];
                                   }
                               }];
}

- (void)showAccessCalendarsPrompt
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Event", nil)
                                                        message:NSLocalizedString(@"This app does not have access to your calendars. You can enable access in Privacy Settings.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - EKEventEditViewDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:NO
                                   completion:^{
                                       if (action == EKEventEditViewActionSaved &&
                                           controller.event) {
                                           [self saveEventButtonTapAction:controller.event];
                                       }
         
    }];
}
@end
