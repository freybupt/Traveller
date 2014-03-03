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
#import "CalendarColorManager.h"
#import "TripManager.h"
#import "Trip.h"
#import "City.h"
#import "CalendarView.h"
#import "CalendarViewController.h"
#import "MyScheduleTableCell.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "AddDestinationViewController.h"


static CGFloat kUIAnimationDuration = 0.3f;
static CGFloat kMyScheduleYCoordinate = 280.0f;
static CGFloat kActionButtonHeight = 35.0f;



@interface CalendarViewController () <DSLCalendarViewDelegate, EKEventEditViewDelegate, EKEventViewDelegate, UINavigationControllerDelegate, MZFormSheetBackgroundWindowDelegate>

@property (nonatomic, assign) BOOL hasLoadedCalendar;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSArray *sortedDays;
@property (nonatomic, strong) NSDateFormatter *sectionDateFormatter;

//Customized Calendar View
@property (nonatomic, weak) IBOutlet CalendarView *calendarView;
@property (nonatomic, strong) DSLCalendarRange *currentDateRange;
@property (nonatomic, assign) BOOL isScheduleExpanded;

@property (nonatomic, strong) NSMutableArray *activeTripRangeArray;


@property (nonatomic, strong) NSMutableArray *numberOutput;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // The Add button is initially disabled
    self.addButton.enabled = NO;
    self.isScheduleExpanded = YES;
    //init calendar view
    self.calendarView.delegate = self;

    //set up default date formatter
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEE, MMM dd"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessGrantedForCalendar:) name:kGrantCalendarAccessNotification object:[CalendarManager sharedManager]];
    
    [self.destinationTextField addTarget:self
                    action:@selector(destinationUpdated:)
          forControlEvents:UIControlEventEditingChanged];
    [self.departureLocationTextField addTarget:self
                                        action:@selector(departureCityUpdated:)
                              forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTripInfo:) name:kTripChangeNotification object:[TripManager sharedManager]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.hasLoadedCalendar) {
        CalendarManager *calendarManager = [CalendarManager sharedManager];
        [calendarManager checkEventStoreAccessForCalendar];
    }
    
    [self performSelector:@selector(adjustScheduleView:) withObject:self afterDelay:0.5];
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
    else if(buttonTapped == self.confirmTripSwitch){
        //show confirm view
        self.planTripView.hidden = YES;
        self.mapView.hidden = YES;
        self.confirmTripView.hidden = NO;
        self.planTripSwitch.backgroundColor = [UIColor lightTextColor];
        self.mapSwitch.backgroundColor = [UIColor lightTextColor];
        self.confirmTripSwitch.backgroundColor = [UIColor whiteColor];
        //TODO: replan the trip details
    }
    else if(buttonTapped == self.mapSwitch){
        self.planTripView.hidden = NO;
        self.mapView.hidden = NO;
        self.confirmTripView.hidden = YES;
        self.planTripSwitch.backgroundColor = [UIColor lightTextColor];
        self.mapSwitch.backgroundColor = [UIColor whiteColor];
        self.confirmTripSwitch.backgroundColor = [UIColor lightTextColor];

    }
}

- (IBAction)adjustScheduleView:(id)sender
{
    [self hideDestinationPanel:nil];
    
    CalendarViewController __weak *weakSelf = self;
    if (self.isScheduleExpanded) {
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.scheduleTableView setFrame:CGRectMake(0, kMyScheduleYCoordinate, self.view.frame.size.width, self.planTripView.frame.size.height - kMyScheduleYCoordinate - kActionButtonHeight)];
        }];
        
        self.isScheduleExpanded = NO;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowUp.png"] forState:UIControlStateNormal];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.scheduleTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.planTripView.frame.size.height - kActionButtonHeight)];
        }];
        
        self.isScheduleExpanded = YES;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowDown.png"] forState:UIControlStateNormal];
    }
    
}


#pragma mark - Destination Panel

- (IBAction)showDestinationPanel:(id)sender
{
    if ([sender isKindOfClass:[Trip class]]) {
        Trip *activeTrip = (Trip *)sender;
        self.destinationTextField.text = activeTrip.destinationCity.cityFullName;
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
        Trip *trip = [[Trip alloc] initWithDateRange:self.currentDateRange
                                       departureCity:self.departureLocationTextField.text
                                      andDestination:self.destinationTextField.text
                                         isRoundTrip:NO];
        
        TripManager *tripManager = [TripManager sharedManager];
        [tripManager addTripToActiveList:trip];
    }
    
    self.calendarView.selectedRange = self.currentDateRange;
    [self hideDestinationPanel:nil];
}

- (IBAction)cancelTripChange:(id)sender
{
    self.currentDateRange = nil;
    self.calendarView.selectedRange = nil;
    if (self.calendarView.editingTrip && self.calendarView.originalTrip) {
        [[TripManager sharedManager] modifyTrip:self.calendarView.editingTrip toNewTrip:self.calendarView.originalTrip];
        self.calendarView.editingTrip = nil;
        self.calendarView.originalTrip = nil;
    }
    [self hideDestinationPanel:nil];
    
}


- (IBAction)deleteCurrentTrip:(id)sender
{
    if (self.calendarView.originalTrip) {
        [[TripManager sharedManager] deleteTrip:self.calendarView.originalTrip];
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
    [self.calendarView updateCalendarView];
}


#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView shouldHighlightTrip:(Trip *)trip
{
    self.destinationTextField.text = trip.destinationCity.cityFullName;
    [self showDestinationPanel:trip];

}

- (void)calendarView:(DSLCalendarView *)calendarView didModifytrip:(Trip *)old toNewTrip:(Trip *)updatedTrip
{
    updatedTrip.destinationCity = [[City alloc] initWithCityName:self.destinationTextField.text];
    [[TripManager sharedManager] modifyTrip:old toNewTrip:updatedTrip];
    [self.calendarView updateCalendarView];
}

- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        self.currentDateRange = range;
        //TODO: update My schedule events - show all the selected events
//        [self fetchEvents];
//        [self.scheduleTableView reloadData];
        
        //show destination popup
//        [self showDestinationPopup:nil];
        [self performSelector:@selector(showDestinationPanel:) withObject:self afterDelay:0.1];
    }
    else {
        self.currentDateRange = nil;
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
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

- (void)calendarView:(DSLCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents *)month duration:(NSTimeInterval)duration {
    NSLog(@"Will show %@ in %.3f seconds", month, duration);
}

- (void)calendarView:(DSLCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents *)month {
    NSLog(@"Now showing %@", month);
//    [self fetchEvents];
//    [self.scheduleTableView reloadData];
    
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedDays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count =[[self.sections objectForKey:[self.sortedDays objectAtIndex:section]] count];
	return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *headerDate = [self.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:headerDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyScheduleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    // Get the event at the row selected and display its title
    EKEvent *event = [[self.sections objectForKey:[self.sortedDays objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [cell setWithEvent:event];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the destination event view controller
    EKEventViewController* eventViewController = [[EKEventViewController alloc] init];
    eventViewController.delegate = self;
    // Set the view controller to display the selected event
    eventViewController.event = [[self.sections objectForKey:[self.sortedDays objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // Allow event editing
    eventViewController.allowsEditing = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:eventViewController];
    navigationController.delegate = self;
    //now present this navigation controller as modally
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    }
    else{
        self.hasLoadedCalendar = YES;
        [self.calendarView updateCalendarView];
        // Enable the Add button
        self.addButton.enabled = YES;
        // Fetch all events happening in the next 24 hours and put them into eventsList
        [self fetchEvents];
        // Update the UI with the above events
        [self.scheduleTableView reloadData];
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
    
    CalendarManager *calendarManager = [CalendarManager sharedManager];
    // We will only search the default calendar for our events
    if (calendarManager.eventStore.defaultCalendarForNewEvents) {
        NSArray *calendarArray = [NSArray arrayWithObject:calendarManager.eventStore.defaultCalendarForNewEvents];
        
        //if user has selected a date range, show the evnets in between
        if (self.currentDateRange) {
            startDate = self.currentDateRange.startDay.date;
            endDate = self.currentDateRange.endDay.date;
            if ([endDate isEqualToDate: startDate]) {
                //show one full day
                endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                        toDate:startDate
                                                                       options:0];
            }
            else{
                //show to the end of the day
                endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                        toDate:endDate
                                                                       options:0];
            }
        }
        
        // Create the predicate
        NSPredicate *predicate = [calendarManager.eventStore predicateForEventsWithStartDate:startDate
                                                                                     endDate:endDate
                                                                                   calendars:calendarArray];
        // Fetch all events that match the predicate
        NSMutableArray *events = [NSMutableArray arrayWithArray:[calendarManager.eventStore eventsMatchingPredicate:predicate]];
        
        // Initialize the events list
        self.sections = [[NSMutableDictionary alloc] init];
        for (EKEvent *event in events)
        {
            // Reduce event start date to date components (year, month, day)
            NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
            
            // If we don't yet have an array to hold the events for this day, create one
            NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
            if (eventsOnThisDay == nil) {
                eventsOnThisDay = [NSMutableArray array];
                
                // Use the reduced date as dictionary key to later retrieve the event list this day
                [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
            }
            
            // Add the event to the list for this day
            [eventsOnThisDay addObject:event];
        }
        
        // Create a sorted list of days
        NSArray *unsortedDays = [self.sections allKeys];
        self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
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
    [controller dismissViewControllerAnimated:YES completion:^
     {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // Re-fetch all events happening in the next 24 hours
                 [self fetchEvents];
                 // Update the UI with the above events
                 [weakSelf.scheduleTableView reloadData];
             });
         }
     }];
}


- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action
{
    CalendarViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Re-fetch all events happening in the next 24 hours
             [self fetchEvents];
             // Update the UI with the above events
             [weakSelf.scheduleTableView reloadData];
             
             //dismiss detail if event is deleted
             if (action == EKEventViewActionDeleted) {
                 [weakSelf performSelector: @selector(dismissDetail) withObject: weakSelf afterDelay: 0.5];
             }
         });
     }];
    
    
}

- (void)dismissDetail
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
