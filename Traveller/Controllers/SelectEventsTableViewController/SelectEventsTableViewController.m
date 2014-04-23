//
//  SelectEventsTableViewController.m
//  Traveller
//
//  Created by Shirley on 2014-04-17.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "SelectEventsTableViewController.h"
#import "Checkbox.h"
#import "MZFormSheetController.h"

@interface SelectEventsTableViewController () <MZFormSheetBackgroundWindowDelegate, UITextFieldDelegate>
@end

@implementation SelectEventsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button tap action
- (IBAction)checkBoxTapAction:(id)sender
{
    Checkbox *checkbox = (Checkbox *)sender;
    
    CGPoint position = [checkbox convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    event.isSelected = [NSNumber numberWithBool:checkbox.checked];
    [[DataManager sharedInstance] saveEvent:event
                                    context:self.managedObjectContext];
    MyScheduleTableCell *cell = (MyScheduleTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([event.isSelected boolValue]) {
        [cell.eventLocationTextField becomeFirstResponder];
        
        //move cell to view top
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height/2.2)];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

}

#pragma mark - NSFetchedResultController configuration
- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"(uid == %@)", [MockManager userid]];
}

#pragma mark - UITableViewDelegate

- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.event = event;
    cell.eventTitleLabel.text = event.title;
    if ([event.allDay boolValue]) {
        cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        cell.eventTimeLabel.text = [formatter stringFromDate:event.startDate];
    }
    if (event.toCity) {
        cell.eventLocationTextField.text = [NSString stringWithFormat:@"%@, %@",
                                            event.toCity.cityName, event.toCity.countryName];
    }
    
    cell.eventLocationLabel.text = event.location;
    cell.eventLocationTextField.autocompleteType = HTAutocompleteTypeCity;
    cell.eventLocationTextField.delegate = self;
    cell.checkBox.checked = [event.isSelected boolValue];
    
    [cell.checkBox addTarget:self
                      action:@selector(checkBoxTapAction:)
            forControlEvents:UIControlEventValueChanged];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyScheduleTableCell *cell = (MyScheduleTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkBox.checked = !cell.checkBox.checked;
    [self checkBoxTapAction:cell.checkBox];

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//| ----------------------------------------------------------------------------
//  Because a custom accessory view is used, this method is never invoked by
//  the table view.  If one of the standard UITableViewCellAccessoryTypes were
//  used instead, the table view would invoke this method in response to a tap
//  on the accessory.
//
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}


//| ----------------------------------------------------------------------------
//! IBAction that is called when the value of a checkbox in any row changes.
//
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    // Lookup the index path of the cell whose checkbox was modified.
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    Event *anEvent = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self editEventButtonTapAction:anEvent];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height)];
    
    NSArray *array = [textField.text componentsSeparatedByString:@", "];
    if ([array count] == 0) {
        return NO;
    }
    
    NSString *cityName = [[array objectAtIndex:0] uppercaseStringToIndex:1];
    City *city = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                           context:self.managedObjectContext];
    if (city) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textField.frame.origin];
        Event *anEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
        anEvent.toCity = city;
        [[DataManager sharedInstance] saveEvent:anEvent
                                        context:self.managedObjectContext];
    }
	
    
    return NO;
}

#pragma mark -
#pragma mark Accessibility

//| ----------------------------------------------------------------------------
//! Utility method for configuring a cell's accessibilityValue based upon the
//! current checkbox state.
//
- (void)updateAccessibilityForCell:(UITableViewCell*)cell
{
    // The cell's accessibilityValue is the Checkbox's accessibilityValue.
    cell.accessibilityValue = cell.accessoryView.accessibilityValue;
}

#pragma mark -
#pragma mark Fetch events
- (void)fetchEvents
{
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:3600000000];
    NSArray *events = [[CalendarManager sharedManager] fetchEventsFromStartDate:startDate
                                                                      toEndDate:endDate];
        
    // Initialize the events list for synchronizing
    // Add events for those not in local storage
    for (EKEvent *event in events)
    {
        [[DataManager sharedInstance] addEventWithEKEvent:event
                                                  context:self.managedObjectContext];
    }
    
    // Remove events for those not in calendar
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *ekEvent = [eventStore eventWithIdentifier:event.eventIdentifier];
        if (!ekEvent) {
            [self deleteEventButtonTapAction:event];
        }
    }];
    
    NSError *error = nil;
    [self.fetchedResultsController.fetchRequest setPredicate:[self predicate]];
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark EKEventEditViewDelegate
// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    SelectEventsTableViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:^{
        if (action == EKEventEditViewActionSaved &&
            controller.event) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf saveEventButtonTapAction:controller.event];
            });
        } else if (action == EKEventEditViewActionDeleted) {
            Event *event = [[DataManager sharedInstance] getEventWithEventIdentifier:controller.event.eventIdentifier
                                                                             context:self.managedObjectContext];
            [weakSelf deleteEventButtonTapAction:event];
        }
    }];
}

- (void)eventViewController:(EKEventViewController *)controller
      didCompleteWithAction:(EKEventViewAction)action
{
    SelectEventsTableViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:^{
        if (action == EKEventViewActionDone &&
            controller.event) {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            EKEvent *event = [eventStore eventWithIdentifier:controller.event.eventIdentifier];
            if (event) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf saveEventButtonTapAction:controller.event];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Event *event = [[DataManager sharedInstance] getEventWithEventIdentifier:controller.event.eventIdentifier
                                                                                     context:self.managedObjectContext];
                    [weakSelf deleteEventButtonTapAction:event];
                });
            }
        }
    }];
}
@end
