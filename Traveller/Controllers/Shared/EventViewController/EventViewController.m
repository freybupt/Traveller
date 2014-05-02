//
//  EventViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-18.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()
@property (nonatomic, assign) BOOL hasLoadedCalendar;
@end

@implementation EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Event", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotification];
}

- (void)viewDidUnload
{
    [self unregisterNotification];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hasLoadedCalendar = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLoadedCalendar"];
    if (!self.hasLoadedCalendar) {
        CalendarManager *calendarManager = [CalendarManager sharedManager];
        [calendarManager checkEventStoreAccessForCalendar];
    }
}


#pragma mark -
#pragma mark Access Calendar
// This method is called when the user has granted permission to Calendar
- (void)accessGrantedForCalendar:(NSNotification *)notification
{
    
    NSDictionary *dict = [notification userInfo];
    BOOL isGranted = [[dict objectForKey:@"hasAccess"] boolValue];
    if (!isGranted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cal need permission for Calendar" message:@"You can edit it in Settings -> Privacy"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        self.hasLoadedCalendar = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoadedCalendar"];
        // Enable the Add button
        // Fetch all events happening in the next 24 hours and put them into eventsList
        [self fetchEvents];
        [MockManager sharedInstance];
    }
    
}

#pragma mark - UI IBAction
// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEventButtonTapAction:(id)sender
{
    CalendarManager *calendarManager = [CalendarManager sharedManager];
    
	// Create an instance of EKEventEditViewController
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
	
	// Set addController's event store to the current event store
	addController.eventStore = calendarManager.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}

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
    return [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
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

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
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
    // Overriding the method in subclass
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // Overriding the method in subclass
}

#pragma mark - EKEventEditViewDelegate
// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{

}

- (void)eventViewController:(EKEventViewController *)controller
      didCompleteWithAction:(EKEventViewAction)action
{

}

#pragma mark - Fetch events
- (void)fetchEvents
{
    // Overriding the method in subclass
}

#pragma mark - NSNotificationCenter
- (void)registerNotification
{
    // Enable this if we would like to sync after users edit events in the system Calendar
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchEvents)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessGrantedForCalendar:)
                                                 name:kGrantCalendarAccessNotification
                                               object:[CalendarManager sharedManager]];
}

- (void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGrantCalendarAccessNotification
                                                  object:[CalendarManager sharedManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}
@end
