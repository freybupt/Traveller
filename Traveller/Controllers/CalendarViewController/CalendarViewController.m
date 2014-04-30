//
//  ViewController.m
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Mapkit/MapKit.h>
#import "CalendarViewController.h"
#import "CalendarView.h"
#import "CalendarColorManager.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "AddDestinationViewController.h"
#import "Checkbox.h"
#import "DSLCalendarView.h"
#import "DSLCalendarRange+Trip.h"

static CGFloat kUIAnimationDuration = 0.3f;
static CGFloat kMyScheduleYCoordinate = 344.0f;
static CGFloat kNavigationBarHeight = 64.0f;


@interface CalendarViewController () <DSLCalendarViewDelegate, MZFormSheetBackgroundWindowDelegate>

//Customized Calendar/Map View
@property (nonatomic, weak) IBOutlet CalendarView *calendarView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIView *myScheduleView;
@property (nonatomic, weak) IBOutlet UIView *myScheduleHeaderView;

//my schedule table components
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *expandButton;

//Destination Panel View
@property (nonatomic, weak) IBOutlet DestinationPanelView *destinationPanelView;

@property (nonatomic, strong) DSLCalendarRange *currentDateRange;
@property (nonatomic, strong) DSLCalendarRange *originalDateRange;
@property (nonatomic, strong) NSManagedObjectID *objectID;
@property (nonatomic, assign) BOOL isScheduleExpanded;
@property (nonatomic, assign) BOOL isDestinationPanelActive;
@property (nonatomic, assign) NSInteger userEventCount;

- (IBAction)adjustScheduleView:(id)sender;
- (IBAction)editMySchedule:(id)sender;

- (IBAction)showDestinationPanel:(id)sender;
- (IBAction)hideDestinationPanel:(id)sender;


- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event;

- (IBAction)showMapview:(id)sender;
- (IBAction)showCalendarView:(id)sender;

@end

@implementation CalendarViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The Add button is initially disabled
    self.isScheduleExpanded = YES;
    self.isDestinationPanelActive = NO;
    
    // Init calendar view
    self.calendarView.delegate = self;
    self.calendarView.showDayCalloutView = NO;

    /* Initial map location setup */
    CLLocation *location = [[LocationManager sharedInstance] currentLocation];
    if (location) {
        MKCoordinateRegion region;
        region.center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                           DEFAULT_MAP_COORDINATE_SPAN * _mapView.frame.size.height/_mapView.frame.size.width);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView setRegion:region animated:YES];
        });
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UI IBAction
- (IBAction)calculateTrip:(id)sender
{
    //count user event
    CalendarViewController __weak *weakSelf = self;
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        if ([event.eventType integerValue] == EventTypeDefault) {
            weakSelf.userEventCount++;
        }
    }];
    NSMutableArray *flightEvents = [[NSMutableArray alloc] init];
    //calculate trip plan - should be done at server later
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        [self showActivityIndicatorWithText:@"Planning for your trip"];
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
        //[[TripManager sharedManager] addTripToActiveList:generatedTrip];
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
                //[[TripManager sharedManager] addTripToActiveList:newTrip];
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
        //[[TripManager sharedManager] addTripToActiveList:returnTrip];
        //Uncomment if we would like to add events to trip at the same time
        //[newTrip addToEvent:[NSSet setWithArray:[self.fetchedResultsController fetchedObjects]]];
        [[DataManager sharedInstance] saveTrip:generatedTrip
                                       context:self.managedObjectContext];
    }
    
    
    for (Event *flightEvent in flightEvents) {
        [[DataManager sharedInstance] saveEvent:flightEvent context:self.managedObjectContext];
    }
    
    [[TripManager sharedManager] setTripStage:TripStagePlanTrip];
    //[self fetchEventsWithDateRange:nil];
    
    [self hideActivityIndicator];
}


- (IBAction)showMapview:(id)sender
{
    self.calendarView.hidden = YES;
    self.mapView.hidden = NO;
    [self shrinkMyScheduleView];
}

- (IBAction)showCalendarView:(id)sender
{
    self.calendarView.hidden = NO;
    self.mapView.hidden = YES;
    [self shrinkMyScheduleView];
}


- (IBAction)editMySchedule:(id)sender
{
    //remove flights/hotel/rental car events
    CalendarViewController __weak *weakSelf = self;
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        if ([event.eventType integerValue] != EventTypeDefault) {
            [[DataManager sharedInstance] deleteEvent:event context:weakSelf.managedObjectContext];
        }
    }];
    [self.tableView reloadData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)adjustScheduleView:(id)sender
{
    [self hideDestinationPanel:nil];
    
    if (self.isScheduleExpanded) {
        //show calendarview as default
        self.calendarView.hidden = NO;
        self.mapView.hidden = YES;
        [self shrinkMyScheduleView];
        
    }
    else{
        //show full view
        [self showFullMyScheduleView];
    }
    
}

- (void)shrinkMyScheduleView
{
    if (self.isScheduleExpanded) {
        CalendarViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kMyScheduleYCoordinate, self.view.frame.size.width, self.view.frame.size.height - kMyScheduleYCoordinate)];
        }];
        
        self.isScheduleExpanded = NO;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowUp.png"] forState:UIControlStateNormal];
    }
}

- (void)showFullMyScheduleView
{
    if (!self.isScheduleExpanded) {
        CalendarViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        
        self.isScheduleExpanded = YES;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowDown.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Destination Panel

- (IBAction)showDestinationPanel:(id)sender
{
    if ([sender isKindOfClass:[Trip class]]) {
        Trip *trip = (Trip *)sender;
        self.destinationPanelView.destinationTextField.text = trip.title;
        self.destinationPanelView.confirmDestinationButton.enabled = YES;
        self.destinationPanelView.removeTripButton.hidden = NO;
        
        NSDateComponents *tripStartDateComponents = [trip.startDate dateComponents];
        NSDateComponents *tripEndDateComponents = [[trip.endDate dateAtMidnight] dateComponents];
        // Memorized objectID & original for the process that reverts changes
        if (!self.originalDateRange) {
            self.objectID = trip.objectID;
            self.originalDateRange = [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                                         endDay:tripEndDateComponents];
        }
        self.currentDateRange = [self.currentDateRange joinedCalendarRangeWithTrip:trip];
        trip.startDate = self.currentDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = [self.currentDateRange.endDay dateWithGMTZoneCalendar]; // Trip's endDate has to be equal to actually selected end day
        if ([[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext]) {
            self.calendarView.selectedRange = nil;
        }
    }
    else{
        self.destinationPanelView.destinationTextField.text = @"";
        self.destinationPanelView.confirmDestinationButton.enabled = NO;
        self.destinationPanelView.removeTripButton.hidden = YES;
    }
    
    CalendarViewController __weak *weakSelf = self;
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanelView.frame = CGRectMake(0,
                                                         weakSelf.navigationController.navigationBar.frame.size.height + 20.0f,
                                                         weakSelf.destinationPanelView.frame.size.width,
                                                         weakSelf.destinationPanelView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.isDestinationPanelActive = YES;
        }
    }];
}

- (IBAction)hideDestinationPanel:(id)sender
{
    [self.destinationPanelView.departureLocationTextField resignFirstResponder];
    [self.destinationPanelView.destinationTextField resignFirstResponder];

    CalendarViewController __weak *weakSelf = self;
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanelView.frame = CGRectMake(0, -weakSelf.destinationPanelView.frame.size.height, weakSelf.destinationPanelView.frame.size.width, weakSelf.destinationPanelView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.objectID = nil;
            self.currentDateRange = nil;
            self.originalDateRange = nil;
            self.calendarView.selectedRange = nil;
            self.isDestinationPanelActive = NO;
        }
    }];
    
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

#pragma mark - DSLCalendarViewDelegate methods
/*
- (void)calendarView:(DSLCalendarView *)calendarView
 shouldHighlightTrip:(Trip *)trip
{
    self.destinationPanelView.destinationTextField.text = trip.toCityDestinationCity.cityName;
    [self showDestinationPanel:trip];
}

- (void)calendarView:(DSLCalendarView *)calendarView
       didModifytrip:(Trip *)old
           toNewTrip:(Trip *)updatedTrip
{
    //TODO: autocomplete for city name
    //    updatedTrip.toCityDestinationCity = [[City alloc] initWithCityName:self.destinationTextField.text];
    
    //TODO: save updatedTrip to db
    //    [[TripManager sharedManager] modifyTrip:old toNewTrip:updatedTrip];
}
*/
- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        self.currentDateRange = range;
        
        NSArray *array = [[DataManager sharedInstance] getActiveTripByDateRange:self.currentDateRange
                                                                         userid:[MockManager userid]
                                                                        context:self.managedObjectContext];
        if ([array count] > 1) {
            return;
        }
        Trip *trip = [array lastObject];
        if (self.isDestinationPanelActive &&
            !trip) {
            return;
        }
        [self performSelector:@selector(showDestinationPanel:)
                   withObject:trip
                   afterDelay:0.1];
        
        // Uncomment this if we would like to display my schedule events according to selection
        //[self fetchEventsWithDateRange:range];
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
    //[self fetchEvents];
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2
{
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}

#pragma mark - NSFetchedResultController configuration
- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"(uid == %@) AND (isSelected = %@)", [MockManager userid], [NSNumber numberWithBool:YES]];
}


#pragma mark - UITableViewDelegate
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
    switch ([event.eventType integerValue]) {
        case EventTypeFlight:
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"5h\tnon-stop\tAirCanada"];
            break;
        case EventTypeHotel:
            break;
        case EventTypeRental:
            break;
        case EventTypeDefault:
        default:
            if ([event.location length] > 0) {
                cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
            }
            else{
                cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@", event.toCity.cityName, event.toCity.countryName];
            }
            break;
    }
    if ([event.eventType integerValue] == EventTypeFlight) {
        
    }
    else{
        
    }
    
//    cell.backgroundColor = cell.checkBox.checked ? UIColorFromRGB(0x9bee9e) : [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    switch ([event.eventType integerValue]) {
        case EventTypeFlight:
            break;
        case EventTypeHotel:
            break;
        case EventTypeRental:
            break;
        case EventTypeDefault:
        default:
            if (self.isScheduleExpanded) {
                //show events detail
                [self editEventButtonTapAction:event];
            }
            else if([self.mapView isHidden]){
                //focus in calendar
            }
            else{
                //focus in map
                Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
                City *city = event.toCity;
                MKCoordinateRegion region;
                region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
                region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                                   DEFAULT_MAP_COORDINATE_SPAN * _mapView.frame.size.height/_mapView.frame.size.width);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mapView setRegion:region animated:YES];
                });
            }
            
            break;
    }
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove event from list
        Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataManager sharedInstance] deleteEvent:event context:self.managedObjectContext];
        [self.tableView reloadData];
    }
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
    //[self fetchEventsWithDateRange:nil];
}
/*
- (void)fetchEventsWithDateRange:(DSLCalendarRange *)dateRange
{
    NSPredicate *predicate = [self predicate];
    if (dateRange) {
        NSDate *startDate = [self.currentDateRange.startDay dateWithGMTZoneCalendar];
        NSDate *endDate = [self.currentDateRange.endDay dateWithGMTZoneCalendar];
        endDate = [endDate dateByAddingTimeInterval:60 * 60 * 24 - 1];
        predicate = [NSPredicate predicateWithFormat:@"(uid == %@) AND (startDate >= %@) AND (endDate <= %@) AND isSelected == '1'", [MockManager userid], startDate, endDate];
    }
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self hideActivityIndicator];
    [self.tableView reloadData];
    [self performSelector:@selector(drawCalendarDayViewForEvent)
               withObject:nil
               afterDelay:0.3f];
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
        [UIView transitionWithView:dayView duration:0.3f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [dayView.layer displayIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];

    // TODO: The step causes a crash, not sure if it's necessary for calculateTrip (Reset simulator -> build -> Next button -> Crash)
    // [self confirmTripChange:nil];
}
*/

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
