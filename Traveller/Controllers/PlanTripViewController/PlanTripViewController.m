//
//  PlanTripViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 5/01/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PlanTripViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "AddDestinationViewController.h"


@interface PlanTripViewController () <MZFormSheetBackgroundWindowDelegate>
//my schedule table components
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, assign) NSInteger userEventCount;

- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event;

@end

@implementation PlanTripViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Register self.managedObjectContext to share with CalendarDayView
    [[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    
    [self.destinationPanelView.confirmDestinationButton addTarget:self
                                                           action:@selector(confirmTripChange:)
                                                 forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.cancelEditDestinationButton addTarget:self
                                                              action:@selector(cancelTripChange:)
                                                    forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.removeTripButton addTarget:self
                                                   action:@selector(deleteCurrentTrip:)
                                         forControlEvents:UIControlEventTouchUpInside];
    
    if ([[TripManager sharedManager] tripStage] == TripStageSelectEvent) {
        [self calculateTrip:nil];
    }
}

#pragma mark - UI IBAction
- (IBAction)calculateTrip:(id)sender
{
    //count user event
    PlanTripViewController __weak *weakSelf = self;
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        if ([event.eventType integerValue] == EventTypeDefault) {
            weakSelf.userEventCount++;
        }
    }];
    NSMutableArray *flightEvents = [[NSMutableArray alloc] init];
    //calculate trip plan - should be done at server later
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        //TODO: get city of current location
        NSString *cityName = @"Vancouver";
        City *departureCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                                        context:self.managedObjectContext];
        //trip from departure city to first destination
        Trip *generatedTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        Event *lastEvent = [self.fetchedResultsController fetchedObjects][0];
        generatedTrip.toCityDepartureCity = departureCity;
        generatedTrip.toCityDestinationCity = lastEvent.toCity;
        generatedTrip.startDate = [[lastEvent.startDate dateAtFourPM] dateByAddingTimeInterval:-60*60*48]; //one day before first event
        generatedTrip.endDate = lastEvent.endDate;
        //Uncomment if we would like to add events to trip at the same time
        //[generatedTrip addToEvent:[NSSet setWithArray:[self.fetchedResultsController fetchedObjects]]];
        [[DataManager sharedInstance] saveTrip:generatedTrip
                                       context:self.managedObjectContext];
        
        
        City *lastCity = departureCity;
        NSMutableArray *tripArray = [[NSMutableArray alloc] init];
        for (NSUInteger index = 0; index < self.userEventCount; index++) {
            Event *event = [self.fetchedResultsController fetchedObjects][index];
            if (![[event.toCity.cityName lowercaseString] isEqualToString:[lastCity.cityName lowercaseString]]) {
                //create a new trip
                Trip *newTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
                newTrip.toCityDepartureCity = lastCity;
                newTrip.toCityDestinationCity = event.toCity;
                newTrip.startDate = [lastEvent.endDate dateAtFourPM];
                newTrip.endDate = event.endDate;
                //Uncomment if we would like to add an event to trip at the same time
                //[newTrip addToEventObject:event];
                generatedTrip = newTrip;
                [tripArray addObject:newTrip];
                
                //add flight event
                if ([event.eventType integerValue] == EventTypeDefault) {
                    Event *flightEvent = [[DataManager sharedInstance] newEventWithContext:self.managedObjectContext];
                    flightEvent.title = [NSString stringWithFormat:@"Flight to %@", event.toCity.cityName];
                    flightEvent.eventType = [NSNumber numberWithInteger: EventTypeFlight];
                    flightEvent.startDate = [[event.startDate dateAtFourPM] dateByAddingTimeInterval:-60*60*24]; //one day before first event
                    flightEvent.endDate = event.startDate;
                    flightEvent.isSelected = [NSNumber numberWithBool:YES];
                    [flightEvents addObject:flightEvent];
                }
            }
            else{
                //TODO: update trip end date
                generatedTrip.endDate = event.endDate;
                [[DataManager sharedInstance] saveTrip:generatedTrip context:self.managedObjectContext];
            }
            lastCity = event.toCity;
            lastEvent = event;
        }
        
        [tripArray enumerateObjectsUsingBlock:^(Trip *trip, NSUInteger idx, BOOL *stop) {
            [[DataManager sharedInstance] saveTrip:trip
                                           context:self.managedObjectContext];
        }];
        
        //trip from last city to home
        Trip *returnTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        returnTrip.toCityDepartureCity = lastCity;
        returnTrip.toCityDestinationCity = departureCity;
        returnTrip.startDate = [lastEvent.endDate dateAtFourPM];
        returnTrip.endDate = [lastEvent.endDate dateByAddingTimeInterval:60*60*24];
        //Uncomment if we would like to add events to trip at the same time
        //[newTrip addToEvent:[NSSet setWithArray:[self.fetchedResultsController fetchedObjects]]];
        [[DataManager sharedInstance] saveTrip:generatedTrip
                                       context:self.managedObjectContext];
    }
    
    
    for (Event *flightEvent in flightEvents) {
        [[DataManager sharedInstance] saveEvent:flightEvent context:self.managedObjectContext];
    }
    
    [[TripManager sharedManager] setTripStage:TripStagePlanTrip];

    [self hideActivityIndicator];
}

- (IBAction)confirmTripChange:(id)sender
{
    [self.destinationPanelView.destinationTextField resignFirstResponder];
    
    Trip *trip = nil;
    if (self.objectID) {
        trip = (Trip *)[self.managedObjectContext objectWithID:self.objectID];
    }
    if (!trip) {
        trip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        trip.startDate = self.currentDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = [self.currentDateRange.endDay dateWithGMTZoneCalendar]; // Trip's endDate has to be equal to actually selected end day
    }
    
    if ([self.destinationPanelView.destinationTextField.text length] > 0) {
        trip.title = self.destinationPanelView.destinationTextField.text;
        
        City *toCity = nil;
        NSArray *array = [self.destinationPanelView.destinationTextField.text componentsSeparatedByString:@", "];
        if ([array count] > 1) {
            NSString *cityName = [[array objectAtIndex:0] uppercaseStringToIndex:1];
            toCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                                     context:self.managedObjectContext];
        }
        if (toCity) {
            trip.toCityDestinationCity = toCity;
        }
    }
    
    // TODO: Add departure city
    if (self.currentDateRange) {
        NSDate *startDate = [self.currentDateRange.startDay dateWithGMTZoneCalendar];
        NSDate *endDate = [self.currentDateRange.endDay dateWithGMTZoneCalendar];
        endDate = [endDate dateByAddingTimeInterval:60 * 60 * 24 - 1];
        
        NSMutableArray *mArray = [NSMutableArray new];
        for (Event *event in [self.fetchedResultsController fetchedObjects]) {
            if ([event.startDate compare:startDate] >= 0 &&
                [event.endDate compare:endDate] <= 0) {
                [mArray addObject:event];
            }
        }

        [trip removeToEvent:trip.toEvent];
        if ([mArray count] != 0) {
            [trip addToEvent:[NSSet setWithArray:mArray]];
        }
        
        self.originalDateRange = [[DSLCalendarRange alloc] initWithStartDay:self.currentDateRange.startDay
                                                                     endDay:self.currentDateRange.endDay];
    }

    if ([[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext]) {
        [self hideDestinationPanel:nil];
    }
}

- (IBAction)cancelTripChange:(id)sender
{
    Trip *trip = nil;
    if (self.objectID) {
        trip = (Trip *)[self.managedObjectContext objectWithID:self.objectID];
    }
    if (trip) {
        trip.startDate = self.originalDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = [self.originalDateRange.endDay dateWithGMTZoneCalendar]; // Trip's endDate has to be equal to actually selected end day
        [[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext];
    }

    [self hideDestinationPanel:nil];
}


- (IBAction)deleteCurrentTrip:(id)sender
{
    NSArray *array = [[DataManager sharedInstance] getActiveTripByDateRange:self.currentDateRange
                                                                     userid:[MockManager userid]
                                                                    context:self.managedObjectContext];
    if ([array count] != 1) {
        return;
    }
    Trip *trip = [array lastObject];
    if ([[DataManager sharedInstance] deleteTrip:trip
                                         context:self.managedObjectContext]) {
        [self hideDestinationPanel:nil];
    }
}

- (void)updateTripInfo:(NSNotification *)userinfo
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
}
@end
