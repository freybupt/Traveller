//
//  SelectEventsTableViewController.m
//  Traveller
//
//  Created by Shirley on 2014-04-17.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "SelectEventsTableViewController.h"
#import "MyScheduleTableCell.h"
#import "Checkbox.h"
#import "CalendarManager.h"
#import "MZFormSheetController.h"

@interface SelectEventsTableViewController () <EKEventEditViewDelegate, EKEventViewDelegate, UINavigationControllerDelegate, MZFormSheetBackgroundWindowDelegate>
@property (nonatomic, strong) NSMutableArray *selectedEvents;
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
}


- (void)viewDidAppear:(BOOL)animated
{
    [self fetchEvents];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // Raw Date String -> NSDate
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    // NSDate -> Formatted Date String
    [formatter setDateFormat:@"EEE, MMM dd"];
    NSString *formattedDateString = [formatter stringFromDate:date];
    
    return formattedDateString;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyScheduleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (!cell) {
        cell = [[MyScheduleTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"eventCell"];
    }
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.eventTitleLabel.text = event.title;
    if ([event.allDay boolValue]) {
        cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        cell.eventTimeLabel.text = [formatter stringFromDate:event.startDate];
    }
    cell.eventLocationLabel.text = event.location;
    cell.checkBox.checked = [self.selectedEvents containsObject:event];
    cell.backgroundColor = cell.checkBox.checked ? UIColorFromRGB(0x9bee9e) : [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    MyScheduleTableCell *cell = (MyScheduleTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkBox.checked = !cell.checkBox.checked;
    cell.backgroundColor = cell.checkBox.checked ? UIColorFromRGB(0x9bee9e) : [UIColor whiteColor];
    
    [self.selectedEvents containsObject:event] ? [self.selectedEvents removeObject:event] : [self.selectedEvents addObject:event];
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

//| ----------------------------------------------------------------------------
//  Because a custom accessory view is used, this method is never invoked by
//  the table view.  If one of the standard UITableViewCellAccessoryTypes were
//  used instead, the table view would invoke this method in response to a tap
//  on the accessory.
//
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
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
        
    CalendarManager *calendarManager = [CalendarManager sharedManager];
    // We will only search the default calendar for our events
    if (calendarManager.eventStore.defaultCalendarForNewEvents) {
        NSArray *calendarArray = [NSArray arrayWithObject:calendarManager.eventStore.defaultCalendarForNewEvents];

        NSDate *startDate = [NSDate date];
        NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:3600000000];
        
        // Create the predicate
        NSPredicate *predicate = [calendarManager.eventStore predicateForEventsWithStartDate:startDate
                                                                                     endDate:endDate
                                                                                   calendars:calendarArray];
        // Fetch all events that match the predicate
        NSMutableArray *events = [NSMutableArray arrayWithArray:[calendarManager.eventStore eventsMatchingPredicate:predicate]];
        
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
    }
    
    [self refreshScheduleTable];
}

- (void)refreshScheduleTable
{
    NSError *error = nil;
    [self.fetchedResultsController.fetchRequest setPredicate:[self predicate]];
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];

}


#pragma mark -
#pragma mark Add a new event

// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEvent:(id)sender
{
	CalendarManager *calendarManager = [CalendarManager sharedManager];
    
	// Create an instance of EKEventEditViewController
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
	
	// Set addController's event store to the current event store
	addController.eventStore = calendarManager.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}


#pragma mark -
#pragma mark Event Actions

- (IBAction)saveEventButtonTapAction:(EKEvent *)event
{
    if ([[DataManager sharedInstance] getEventWithEventIdentifier:event.eventIdentifier
                                                          context:self.managedObjectContext]) {
        [self updateEventButtonTapAction:event];
        return;
    }
    
    if (![[DataManager sharedInstance] addEventWithEKEvent:event
                                                   context:self.managedObjectContext]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DataManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when inserting an event item", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)editEventButtonTapAction:(Event *)event
{
    /* Create an eventStore with an event associated with eventIdentifier for EKEventEditViewController */
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *ekEvent = [eventStore eventWithIdentifier:event.eventIdentifier];
    
    if (!event) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Calendar", nil)
                                                            message:NSLocalizedString(@"The event item is not in Calendar anymore.", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    EKEventViewController *vc = [[EKEventViewController alloc] init];
    vc.allowsEditing = YES;
    vc.event = ekEvent;
    vc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:^{}];
}

- (IBAction)updateEventButtonTapAction:(EKEvent *)event
{
    if (![[DataManager sharedInstance] updateEventWithEKEvent:event
                                                      context:self.managedObjectContext]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DataManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when inserting an event item", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)deleteEventButtonTapAction:(Event *)event
{
    [[DataManager sharedInstance] deleteEvent:event
                                      context:self.managedObjectContext];
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

#pragma mark - NSFetchedResultController configuration

- (NSString *)entityName
{
    return @"Event";
}

- (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:[self entityName]
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"(uid == %@)", [MockManager userid]];
}

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

- (NSString *)sectionNameKeyPath
{
    return @"startDate";
}
@end
