//
//  ViewController.m
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarViewController.h"

#import <EventKit/EventKit.h>
#import "CalendarManager.h"
#import "CalendarView.h"
#import "CalendarViewController.h"
#import "MyScheduleTableCell.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "AddDestinationViewController.h"
#import "Checkbox.h"
#import "DSLCalendarView.h"

static CGFloat kUIAnimationDuration = 0.3f;
static CGFloat kMyScheduleYCoordinate = 280.0f;

@interface CalendarViewController () <DSLCalendarViewDelegate, EKEventEditViewDelegate, EKEventViewDelegate, UINavigationControllerDelegate, MZFormSheetBackgroundWindowDelegate>

@property (nonatomic, assign) BOOL hasLoadedCalendar;
@property (nonatomic, strong) NSDateFormatter *sectionDateFormatter;

//Customized Calendar View
@property (nonatomic, weak) IBOutlet CalendarView *calendarView;
@property (nonatomic, strong) DSLCalendarRange *currentDateRange;
@property (nonatomic, assign) BOOL isScheduleExpanded;

@property (nonatomic, strong) NSMutableArray *activeTripRangeArray;
@property (nonatomic, strong) NSMutableArray *selectedEvents;
@property (nonatomic, strong) NSMutableArray *numberOutput;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // The Add button is initially disabled
    self.addButton.enabled = NO;
    self.isScheduleExpanded = NO;
    //init calendar view
    self.calendarView.delegate = self;

    //set up default date formatter
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEE, MMM dd"];
    
    self.selectedEvents = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessGrantedForCalendar:) name:kGrantCalendarAccessNotification object:[CalendarManager sharedManager]];
    
    [self.destinationTextField addTarget:self
                    action:@selector(destinationUpdated:)
          forControlEvents:UIControlEventEditingChanged];
    [self.departureLocationTextField addTarget:self
                                        action:@selector(departureCityUpdated:)
                              forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchEvents)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.hasLoadedCalendar) {
        CalendarManager *calendarManager = [CalendarManager sharedManager];
        [calendarManager checkEventStoreAccessForCalendar];
    }

    //[self performSelector:@selector(adjustScheduleView:) withObject:self afterDelay:0.5];
    [self fetchEvents];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UI IBAction

- (IBAction)switchDidTapped:(id)sender
{
    UIButton *buttonTapped = (UIButton *)sender;
    if (buttonTapped == self.planTripSwitch) {
        //show plan view
        self.planTripView.hidden = NO;
        self.mapView.hidden = YES;
        self.confirmTripView.hidden = YES;
        self.planTripSwitch.backgroundColor = [UIColor whiteColor];
        self.mapSwitch.backgroundColor = [UIColor lightTextColor];
        self.confirmTripSwitch.backgroundColor = [UIColor lightTextColor];
        
    }
//    else if(buttonTapped == self.confirmTripSwitch){
//        //show confirm view
//        self.planTripView.hidden = YES;
//        self.mapView.hidden = YES;
//        self.confirmTripView.hidden = NO;
//        self.planTripSwitch.backgroundColor = [UIColor lightTextColor];
//        self.mapSwitch.backgroundColor = [UIColor lightTextColor];
//        self.confirmTripSwitch.backgroundColor = [UIColor whiteColor];
//        //TODO: replan the trip details
//    }
    else if(buttonTapped == self.mapSwitch){
        self.planTripView.hidden = NO;
        self.mapView.hidden = NO;
        self.confirmTripView.hidden = YES;
        self.planTripSwitch.backgroundColor = [UIColor lightTextColor];
        self.mapSwitch.backgroundColor = [UIColor whiteColor];
        self.confirmTripSwitch.backgroundColor = [UIColor lightTextColor];

    }
}

- (IBAction)editMySchedule:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)adjustScheduleView:(id)sender
{
    [self hideDestinationPanel:nil];
    
    CalendarViewController __weak *weakSelf = self;
    if (self.isScheduleExpanded) {
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.tableView setFrame:CGRectMake(0, kMyScheduleYCoordinate, self.view.frame.size.width, self.planTripView.frame.size.height - kMyScheduleYCoordinate)];
        }];
        
        self.isScheduleExpanded = NO;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowUp.png"] forState:UIControlStateNormal];
    }
    else{
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.planTripView.frame.size.height)];
        }];
        
        self.isScheduleExpanded = YES;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowDown.png"] forState:UIControlStateNormal];
    }
    
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

#pragma mark - Destination Panel

- (IBAction)showDestinationPanel:(id)sender
{
    if ([sender isKindOfClass:[Trip class]]) {
        //Trip *activeTrip = (Trip *)sender;
        //self.destinationTextField.text = activeTrip.destinationCity.cityFullName;
        self.removeTripButton.hidden = NO;
    }
    else{
        self.destinationTextField.text = @"";
        self.confirmDestinationButton.enabled = NO;
        self.removeTripButton.hidden = YES;
    }
    
    CalendarViewController __weak *weakSelf = self;
    //show destination view
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanel.frame = CGRectMake(0, weakSelf.planTripView.frame.origin.y, weakSelf.destinationPanel.frame.size.width, weakSelf.destinationPanel.frame.size.height);
        [weakSelf.tabView setAlpha:0.0];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)hideDestinationPanel:(id)sender
{
    [self.departureLocationTextField resignFirstResponder];
    [self.destinationTextField resignFirstResponder];

    CalendarViewController __weak *weakSelf = self;
    //show destination view
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanel.frame = CGRectMake(0, -weakSelf.destinationPanel.frame.size.height, weakSelf.destinationPanel.frame.size.width, weakSelf.destinationPanel.frame.size.height);
        [weakSelf.tabView setAlpha:1.0];
    } completion:nil];
    
    [self updateTripInfo:nil];
}

- (IBAction)confirmTripChange:(id)sender
{
    if ([self.destinationTextField.text length] > 0 &&  self.calendarView.editingTrip == nil) {
        //save trip
        /*
        Trip *trip = [[Trip alloc] initWithDateRange:self.currentDateRange
                                       departureCity:self.departureLocationTextField.text
                                      andDestination:self.destinationTextField.text
                                         isRoundTrip:NO];
        
        TripManager *tripManager = [TripManager sharedManager];
        [tripManager addTripToActiveList:trip];
        */
    }
    
    self.calendarView.selectedRange = self.currentDateRange;
    [self hideDestinationPanel:nil];
}

- (IBAction)cancelTripChange:(id)sender
{
    self.currentDateRange = nil;
    self.calendarView.selectedRange = nil;
    if (self.calendarView.editingTrip && self.calendarView.originalTrip) {
        //[[TripManager sharedManager] modifyTrip:self.calendarView.editingTrip toNewTrip:self.calendarView.originalTrip];
        self.calendarView.editingTrip = nil;
        self.calendarView.originalTrip = nil;
    }
    [self hideDestinationPanel:nil];
    [self fetchEventsWithDateRange:nil];
    [self performSelector:@selector(drawCalendarDayViewForEvent)
               withObject:nil
               afterDelay:0.3f];
}


- (IBAction)deleteCurrentTrip:(id)sender
{
    if (self.calendarView.originalTrip) {
        //[[TripManager sharedManager] deleteTrip:self.calendarView.originalTrip];
        self.calendarView.selectedRange = nil;
        [self hideDestinationPanel:nil];
    }
}

- (void)destinationUpdated:(id)sender
{
    self.confirmDestinationButton.enabled = ([self.destinationTextField.text length] > 0);
    
}

- (void)departureCityUpdated:(id)sender
{
    
}

- (void)updateTripInfo:(NSNotification *)userinfo
{

}

#pragma mark - DSLCalendarViewDelegate methods
/*
- (void)calendarView:(DSLCalendarView *)calendarView
 shouldHighlightTrip:(Trip *)trip
{
    self.destinationTextField.text = trip.destinationCity.cityFullName;
    [self showDestinationPanel:trip];

}

- (void)calendarView:(DSLCalendarView *)calendarView
       didModifytrip:(Trip *)old
           toNewTrip:(Trip *)updatedTrip
{
    updatedTrip.destinationCity = [[City alloc] initWithCityName:self.destinationTextField.text];
    [[TripManager sharedManager] modifyTrip:old toNewTrip:updatedTrip];
}
*/

- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        self.currentDateRange = range;
        [self performSelector:@selector(showDestinationPanel:) withObject:self afterDelay:0.1];
        [self fetchEventsWithDateRange:self.currentDateRange];
        [self performSelector:@selector(drawCalendarDayViewForEvent)
                   withObject:nil
                   afterDelay:0.3f];
    }
    else {
        self.currentDateRange = nil;
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView
                     didDragToDay:(NSDateComponents *)day
                   selectingRange:(DSLCalendarRange *)range
{
    if (NO) { // Only select a single day
        return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];
    }
    else if (NO) { // Don't allow selections before today
        NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
        
        NSDateComponents *startDate = range.startDay;
        NSDateComponents *endDate = range.endDay;
        
        if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today]) {
            return nil;
        }
        else {
            if ([self day:startDate isBeforeDay:today]) {
                startDate = [today copy];
            }
            if ([self day:endDate isBeforeDay:today]) {
                endDate = [today copy];
            }
            
            return [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
        }
    }
    
    return range;
}

- (void)calendarView:(DSLCalendarView *)calendarView
    willChangeToVisibleMonth:(NSDateComponents *)month
            duration:(NSTimeInterval)duration
{
    NSLog(@"Will show %@ in %.3f seconds", month, duration);
}

- (void)calendarView:(DSLCalendarView *)calendarView
    didChangeToVisibleMonth:(NSDateComponents *)month
{
    NSLog(@"Now showing %@", month);
    [self fetchEvents];
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2
{
    return ([day1.date compare:day2.date] == NSOrderedAscending);
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
    NSDateComponents *oneMonth = [NSDateComponents new];
    oneMonth.month = 1;
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:self.calendarView.visibleMonth];
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneMonth
                                                                    toDate:startDate
                                                                   options:0];
    return [NSPredicate predicateWithFormat:@"(uid == %@) AND (startDate >= %@) AND (endDate <= %@)", [MockManager userid], startDate, endDate];
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
#pragma mark Access Calendar
// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    BOOL isGranted = [[dict objectForKey:@"hasAccess"] boolValue];
    if (!isGranted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cal need permission for Calendar" message:@"You can edit it in Settings -> Privacy"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.calendarView.hidden = YES;
    } else {
        self.hasLoadedCalendar = YES;
        // Enable the Add button
        self.addButton.enabled = YES;
        // Fetch all events happening in the next 24 hours and put them into eventsList
        [self fetchEvents];
    }
    
}

#pragma mark -
#pragma mark Fetch events
- (void)fetchEvents
{
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 1;
    
    //get first and last day of this month
    NSDateComponents *firstDayComponent = [self.calendarView.visibleMonth copy];
    firstDayComponent.day = 1;
    NSRange days = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                                      inUnit:NSMonthCalendarUnit
                                                     forDate:[[NSCalendar currentCalendar] dateFromComponents:firstDayComponent]];
    
    NSDateComponents *lastDateComponent = [self.calendarView.visibleMonth copy];
    lastDateComponent.day = days.length+1;
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:firstDayComponent];
    NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:lastDateComponent];
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
    [self fetchEventsWithDateRange:nil];
    [self performSelector:@selector(drawCalendarDayViewForEvent)
               withObject:nil
               afterDelay:0.3f];
}

- (void)fetchEventsWithDateRange:(DSLCalendarRange *)dateRange
{
    NSPredicate *predicate = [self predicate];
    if (dateRange) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSDate *startDate = [calendar dateFromComponents:self.currentDateRange.startDay];
        NSDate *endDate = [calendar dateFromComponents:self.currentDateRange.endDay];
        endDate = [endDate dateByAddingTimeInterval:60 * 60 * 24 - 1];
        predicate = [NSPredicate predicateWithFormat:@"(uid == %@) AND (startDate >= %@) AND (endDate <= %@)", [MockManager userid], startDate, endDate];
    }
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

- (void)drawCalendarDayViewForEvent
{
    DSLCalendarMonthView *calendarMonthView = (DSLCalendarMonthView *)[self.calendarView cachedOrCreatedMonthViewForMonth:self.calendarView.visibleMonth];
    [[calendarMonthView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CalendarDayView class]]) {
            CalendarDayView *dayView = (CalendarDayView *)obj;
            [dayView setDay:dayView.day];
            // TODO: probably use CalendarDayViewSelectionState to replace UIView tag assignation
            dayView.tag = 0;
            [dayView setNeedsDisplay];
        }
    }];
    
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        NSUInteger flags = NSCalendarCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:flags fromDate:event.startDate];
        
        CalendarDayView *dayView = (CalendarDayView *)[calendarMonthView dayViewForDay:components];
        // TODO: probably use CalendarDayViewSelectionState to replace UIView tag assignation
        dayView.tag = components.year * 10000 + components.month * 100 + components.day;
        [dayView setNeedsDisplay];
    }];
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
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    CalendarViewController * __weak weakSelf = self;
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
    CalendarViewController * __weak weakSelf = self;
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
