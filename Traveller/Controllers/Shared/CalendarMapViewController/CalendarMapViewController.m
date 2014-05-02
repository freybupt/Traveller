//
//  CalendarMapViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarMapViewController.h"
#import "PanoramaViewController.h"

static CGFloat kUIAnimationDuration = 0.3f;
static CGFloat kMyScheduleYCoordinate = 320.0f;
static CGFloat kNavigationBarHeight = 44.0f;

@interface CalendarMapViewController ()
@property (nonatomic, assign) BOOL isScheduleExpanded;
@property (nonatomic, assign) BOOL isDestinationPanelActive;
@end

@implementation CalendarMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showActivityIndicatorWithText:@"Planning your trip...."];
    
    // The Add button is initially disabled
    self.isScheduleExpanded = YES;
    self.isDestinationPanelActive = NO;
    
    // Init calendar view
    self.calendarView.delegate = self;
    self.calendarView.showDayCalloutView = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adjustScheduleView:)];
    tapGesture.numberOfTapsRequired = 1;
    self.myScheduleTitleLabel.userInteractionEnabled = YES;
    [self.myScheduleTitleLabel addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.myScheduleTitleLabel addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.myScheduleTitleLabel addGestureRecognizer:swipeUpGesture];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button tap action

- (IBAction)adjustScheduleView:(id)sender
{
    [self hideDestinationPanel:nil];
    
    if (self.isScheduleExpanded) {
        //show calendarview as default
        [self shrinkMyScheduleView];
        [self showCalendarView:nil];
    }
    else {
        //show full view
        [self showFullMyScheduleView];
    }
    
}

- (IBAction)editMySchedule:(id)sender
{
    switch ([[self.navigationController viewControllers] count]) {
        case 1:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 2:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to repick events?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Repick", nil];
            alertView.tag = 1;
            [alertView show];
            break;
        }
        default:
            //WTF
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
    
}

- (IBAction)showMapview:(id)sender
{
    self.calendarView.hidden = YES;
    self.mapView.hidden = NO;
    [self shrinkMyScheduleView];
    [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53@2x.png"] forState:UIControlStateNormal];
    [self.showMapButton setImage:[UIImage imageNamed:@"map35_red@2x.png"] forState:UIControlStateNormal];
}

- (IBAction)showCalendarView:(id)sender
{
    self.calendarView.hidden = NO;
    self.mapView.hidden = YES;
    [self shrinkMyScheduleView];
    [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53_red@2x.png"] forState:UIControlStateNormal];
    [self.showMapButton setImage:[UIImage imageNamed:@"map35@2x.png"] forState:UIControlStateNormal];
}


- (void)swipeDown:(id)sender
{
    if (self.isScheduleExpanded) {
        [self shrinkMyScheduleView];
        [self showCalendarView:nil];
    }
}

- (void)swipeUp:(id)sender
{
    if (!self.isScheduleExpanded) {
        [self showFullMyScheduleView];
    }
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                //remove flights/hotel/rental car events
                CalendarMapViewController __weak *weakSelf = self;
                [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
                    if ([event.eventType integerValue] != EventTypeDefault) {
                        [[DataManager sharedInstance] deleteEvent:event context:weakSelf.managedObjectContext];
                    }
                }];
                [self.tableView reloadData];
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Confirm Trip
- (IBAction)confirmTrip:(id)sender
{
    [self showActivityIndicatorWithText:@"Booking your trip...\n\nPlease feel free to close the app. \nThis might take a while."];
}



#pragma mark - Schedule view adjustment

- (void)shrinkMyScheduleView
{
    if (_isScheduleExpanded) {
        CalendarMapViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kMyScheduleYCoordinate, self.view.frame.size.width, self.view.frame.size.height - kMyScheduleYCoordinate)];
        }];
        
        _isScheduleExpanded = NO;
        [_expandButton setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
    }
}

- (void)showFullMyScheduleView
{
    if (!_isScheduleExpanded) {
        CalendarMapViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53@2x.png"] forState:UIControlStateNormal];
        [self.showMapButton setImage:[UIImage imageNamed:@"map35@2x.png"] forState:UIControlStateNormal];
        _isScheduleExpanded = YES;
        [_expandButton setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
    }
}

#pragma mark - Destination Panel

- (IBAction)showDestinationPanel:(id)sender
{
    if ([sender isKindOfClass:[Trip class]]) {
        Trip *trip = (Trip *)sender;
        _destinationPanelView.destinationTextField.text = trip.toCityDestinationCity.cityName;
        _destinationPanelView.confirmDestinationButton.enabled = YES;
        _destinationPanelView.removeTripButton.hidden = NO;
        
        NSDateComponents *tripStartDateComponents = [trip.startDate dateComponents];
        NSDateComponents *tripEndDateComponents = [[trip.endDate dateAtMidnight] dateComponents];
        // Memorized objectID & original for the process that reverts changes
        if (!_originalDateRange) {
            _objectID = trip.objectID;
            _originalDateRange = [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                                         endDay:tripEndDateComponents];
        }
        _currentDateRange = [_currentDateRange joinedCalendarRangeWithTrip:trip];
        trip.startDate = _currentDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = [_currentDateRange.endDay dateWithGMTZoneCalendar]; // Trip's endDate has to be equal to actually selected end day
        if ([[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext]) {
            _calendarView.selectedRange = nil;
        }
    }
    else{
        _destinationPanelView.destinationTextField.text = @"";
        _destinationPanelView.confirmDestinationButton.enabled = NO;
        _destinationPanelView.removeTripButton.hidden = YES;
    }
    
    CalendarMapViewController __weak *weakSelf = self;
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanelView.frame = CGRectMake(0,
                                                         weakSelf.navigationController.navigationBar.frame.size.height,
                                                         weakSelf.destinationPanelView.frame.size.width,
                                                         weakSelf.destinationPanelView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            _isDestinationPanelActive = YES;
        }
    }];
}

- (IBAction)hideDestinationPanel:(id)sender
{
    [_destinationPanelView.departureLocationTextField resignFirstResponder];
    [_destinationPanelView.destinationTextField resignFirstResponder];
    
    CalendarMapViewController __weak *weakSelf = self;
    [UIView animateWithDuration:kUIAnimationDuration animations:^{
        weakSelf.destinationPanelView.frame = CGRectMake(0, -weakSelf.destinationPanelView.frame.size.height, weakSelf.destinationPanelView.frame.size.width, weakSelf.destinationPanelView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            _objectID = nil;
            _currentDateRange = nil;
            _originalDateRange = nil;
            _calendarView.selectedRange = nil;
            _isDestinationPanelActive = NO;
        }
    }];
    
}

#pragma mark - DSLCalendarViewDelegate methods
- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        _currentDateRange = range;
        
        NSArray *array = [[DataManager sharedInstance] getActiveTripByDateRange:_currentDateRange
                                                                         userid:[MockManager userid]
                                                                        context:self.managedObjectContext];
        if ([array count] > 1) {
            return;
        }
        Trip *trip = [array lastObject];
        if (_isDestinationPanelActive &&
            !trip) {
            return;
        }
        [self performSelector:@selector(showDestinationPanel:)
                   withObject:trip
                   afterDelay:0.1];
    }
    else {
        _currentDateRange = nil;
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    switch ([event.eventType integerValue]) {
        case EventTypeFlight:
            [self showSampleHotelPanorama];
            break;
        case EventTypeHotel:
            //show hotel panorama view
            [self showSampleHotelPanorama];
            break;
        case EventTypeRental:
            break;
        case EventTypeDefault:
        default:
            if (_isScheduleExpanded) {
                //show events detail
                [self editEventButtonTapAction:event];
            }
            else if([_mapView isHidden]){
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
    }
}


#pragma mark - Hotel

- (void)showSampleHotelPanorama
{
    PanoramaViewController *vc = [[PanoramaViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    CalendarMapViewController * __weak weakSelf = self;
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
    CalendarMapViewController * __weak weakSelf = self;
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
