//
//  CalendarMapViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarMapViewController.h"
#import "PanoramaViewController.h"
#import "MyScheduleTableViewHeaderView.h"

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

    [self showActivityIndicatorWithText:NSLocalizedString(@"Planning your trip....", nil)];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* Set corrent myScheduleView frame */
    CalendarMapViewController __weak *weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height)];
    }];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Do you want to repick events?", nil)
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Repick", nil), nil];
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
    [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53"] forState:UIControlStateNormal];
    [self.showMapButton setImage:[UIImage imageNamed:@"map35_red"] forState:UIControlStateNormal];
}

- (IBAction)showCalendarView:(id)sender
{
    self.calendarView.hidden = NO;
    self.mapView.hidden = YES;
    [self shrinkMyScheduleView];
    [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53_red"] forState:UIControlStateNormal];
    [self.showMapButton setImage:[UIImage imageNamed:@"map35"] forState:UIControlStateNormal];
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
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Schedule view adjustment

- (void)shrinkMyScheduleView
{
    if (_isScheduleExpanded) {
        
        CalendarMapViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kMyScheduleYCoordinate, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height - kMyScheduleYCoordinate)];
            [weakSelf.tableView setContentSize:CGSizeMake(weakSelf.tableView.contentSize.width, weakSelf.tableView.contentSize.height - weakSelf.bookTripView.frame.size.height)];
            weakSelf.bookTripView.hidden = YES;
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
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, weakSelf.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - weakSelf.navigationController.navigationBar.frame.size.height)];
            weakSelf.bookTripView.hidden = NO;
        }];
        [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53"] forState:UIControlStateNormal];
        [self.showMapButton setImage:[UIImage imageNamed:@"map35"] forState:UIControlStateNormal];
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
        NSDateComponents *tripEndDateComponents = [trip.endDate dateComponents];
        // Memorized objectID & original for the process that reverts changes
        if (!_originalDateRange) {
            _objectID = trip.objectID;
            _originalDateRange = [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                                         endDay:tripEndDateComponents];
        }
        _currentDateRange = [_currentDateRange joinedCalendarRangeWithTrip:trip];
        trip.startDate = _currentDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = _currentDateRange.endDay.date; // Trip's endDate has to be equal to actually selected end day
        if ([[DataManager sharedInstance] saveTrip:trip
                                           context:self.managedObjectContext]) {
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
        [self showDestinationPanel:trip];
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

#pragma mark - UITableViewDelegate
- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    cell.eventTitleLabel.text = event.title;
    if ([event.allDay boolValue]) {
        cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        cell.eventTimeLabel.text = [formatter stringFromDate:event ? event.startDate : trip.startDate];
    }
    
    if (!event) {
        cell.eventTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flight to %@", nil), trip.toCityDestinationCity.cityName];
        cell.eventLocationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"5h\tnon-stop\tAirCanada", nil)];
    } else {
        if ([event.location length] > 0) {
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
        }
        else if([event.toCity.cityName length] > 0){
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    if (!event) {
        return;
    }
    City *city = event.toCity;
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
    region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                       DEFAULT_MAP_COORDINATE_SPAN * _mapView.frame.size.height/_mapView.frame.size.width);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView setRegion:region animated:YES];
    });
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataManager sharedInstance] deleteTrip:trip
                                         context:self.managedObjectContext];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [headerView setBackgroundColor:(UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:trip.defaultColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 25)];
    titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
    titleLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"EEE, MMM dd"];
    NSString *formattedDateString = [formatter stringFromDate:trip.startDate];
    titleLabel.text = formattedDateString;
    [headerView addSubview:titleLabel];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width*3/4, 0, tableView.bounds.size.width/4, 25)];
    locationLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.0];
    locationLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0];
    locationLabel.text = trip.toCityDepartureCity.cityName;
    [headerView addSubview:locationLabel];
    
    return headerView;
}


#pragma mark - NSManagedObjectContext
- (void)updateMainContext:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

- (void)mergeChanges:(NSNotification *)notification
{
    NSManagedObjectContext *moc = (NSManagedObjectContext *)[notification object];
    if (moc != self.managedObjectContext &&
        moc.persistentStoreCoordinator == self.managedObjectContext.persistentStoreCoordinator) {
        [self performSelectorOnMainThread:@selector(updateMainContext:)
                               withObject:notification
                            waitUntilDone:NO];
    }
    [self getTripCityColorDictionary];
}

#pragma mark - Trip colours
- (void)getTripCityColorDictionary
{
    // Collect default colours
    if ([[TripManager sharedManager] tripColorDictionary]) {
        [[[TripManager sharedManager] tripColorDictionary] removeAllObjects];
    }
    
    if ([[TripManager sharedManager] tripCityCodeDictionary]) {
        [[[TripManager sharedManager] tripCityCodeDictionary] removeAllObjects];
    }
    
    NSArray *trips = [self.fetchedResultsController fetchedObjects];
    for (Trip *trip in trips) {
        NSDate *startDate = trip.startDate;
        NSDate *endDate = trip.endDate;
        
        [[[TripManager sharedManager] tripCityCodeDictionary] setObject:trip.toCityDepartureCity.cityCode
                                                                 forKey:[NSNumber numberWithInteger:[[startDate dateComponents] uniqueDateNumber]]];
        [[[TripManager sharedManager] tripCityCodeDictionary] setObject:trip.toCityDestinationCity.cityCode
                                                                 forKey:[NSNumber numberWithInteger:[[endDate dateComponents] uniqueDateNumber]]];
        for (NSDate *date = startDate;
             [date compare:[[endDate dateAtMidnight] dateAfterOneDay]] < 0;
             date = [date dateAfterOneDay] ) {
            
            NSDateComponents *dateComponents = [date dateComponents];
            UIColor *defaultColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:trip.defaultColor];
            [[[TripManager sharedManager] tripColorDictionary] setObject:defaultColor
                                                                  forKey:[NSNumber numberWithInteger:[dateComponents uniqueDateNumber]]];
        }
    }
}

#pragma mark - Hotel

- (void)showSampleHotelPanorama
{
    PanoramaViewController *vc = [[PanoramaViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
