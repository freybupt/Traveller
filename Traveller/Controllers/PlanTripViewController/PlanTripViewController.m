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
@property (nonatomic, strong) Itinerary *itinerary;
@property (nonatomic, strong) NSIndexPath *expandedCellIndexPath;
@property (nonatomic, assign) NSInteger totalPrice;


@property (nonatomic, weak) IBOutlet UIView *bookTripView;
@property (nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property (nonatomic, weak) IBOutlet UIButton *bookTripButton;
@property (nonatomic, weak) IBOutlet UIButton *adjustListViewButton;

- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;

@end

@implementation PlanTripViewController
- (void)awakeFromNib
{
    _itinerary = [[DataManager sharedInstance] newItineraryWithContext:self.managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register self.managedObjectContext to share with CalendarDayView
    [[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    
    if ([[TripManager sharedManager] tripStage] == TripStageSelectEvent) {
        [self calculateTrip:nil];
    }
    else{
        [self hideActivityIndicator];
    }
    
    [self.destinationPanelView.confirmDestinationButton addTarget:self
                                                           action:@selector(confirmTripChange:)
                                                 forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.cancelEditDestinationButton addTarget:self
                                                              action:@selector(cancelTripChange:)
                                                    forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.removeTripButton addTarget:self
                                                   action:@selector(deleteCurrentTrip:)
                                         forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)shrinkMyScheduleView
{
    if (self.isScheduleExpanded) {
        
        PlanTripViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kMyScheduleYCoordinate, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height - kMyScheduleYCoordinate)];
            [weakSelf.tableView setContentSize:CGSizeMake(weakSelf.tableView.contentSize.width, weakSelf.tableView.contentSize.height - weakSelf.bookTripView.frame.size.height)];
            weakSelf.bookTripView.hidden = YES;
        }];
        
        self.isScheduleExpanded = NO;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
    }
}

- (void)showFullMyScheduleView
{
    if (!self.isScheduleExpanded) {
        PlanTripViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, weakSelf.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - weakSelf.navigationController.navigationBar.frame.size.height)];
            weakSelf.bookTripView.hidden = NO;
        }];
        [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53"] forState:UIControlStateNormal];
        [self.showMapButton setImage:[UIImage imageNamed:@"map35"] forState:UIControlStateNormal];
        self.isScheduleExpanded = YES;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
    }
}

#pragma mark - UI IBAction
- (IBAction)calculateTrip:(id)sender
{
    NSArray *events = [[DataManager sharedInstance] getEventWithSelected:YES
                                                                 context:self.managedObjectContext];
    if ([events count] == 0) {
        [self hideActivityIndicator];
        return;
    }

    self.totalPrice = 0;
    //add flight and hotel events
    Event *firstEvent = (Event *)[events objectAtIndex:0];
    NSString *cityName = @"Vancouver";
    City *departureCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                                    context:self.managedObjectContext];
    Trip *firstTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
    firstTrip.toCityDepartureCity = departureCity;
    firstTrip.toCityDestinationCity = firstEvent.toCity;
    firstTrip.startDate = [firstEvent.startDate dateBeforeOneDay]; //one day before first event
    firstTrip.endDate = [firstEvent.endDate dateBeforeOneDay];
    firstTrip.toEvent = nil;
    NSInteger randomPrice = arc4random()%500+200;
    self.totalPrice += randomPrice;
    firstTrip.price = [NSNumber numberWithInteger:randomPrice];
    firstTrip.toItinerary = _itinerary;
    if ([[DataManager sharedInstance] saveTrip:firstTrip
                                       context:self.managedObjectContext]) {
        _itinerary.date = firstTrip.startDate;
        _itinerary.title = [NSString stringWithFormat:NSLocalizedString(@"Trip to %@", nil), firstEvent.toCity.cityName];
    }
    
    Trip *firstTripWithEvent = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
    firstTripWithEvent.defaultColor = firstTrip.defaultColor;
    firstTripWithEvent.toCityDepartureCity = firstEvent.toCity;
    firstTripWithEvent.toCityDestinationCity = firstEvent.toCity;
    firstTripWithEvent.startDate = firstEvent.startDate; //one day before first event
    firstTripWithEvent.endDate = firstEvent.endDate;
    firstTripWithEvent.toEvent = firstEvent;
    firstTripWithEvent.price = [NSNumber numberWithInteger:0];
    firstTripWithEvent.toItinerary = _itinerary;
    if ([[DataManager sharedInstance] saveTrip:firstTripWithEvent
                                       context:self.managedObjectContext]) {
        _itinerary.date = firstTripWithEvent.startDate;
        _itinerary.title = [NSString stringWithFormat:NSLocalizedString(@"Event at %@", nil), firstEvent.toCity.cityName];
    }
    
    Event *hotelEvent = [[DataManager sharedInstance] newEventWithContext:self.managedObjectContext];
    hotelEvent.title = [NSString stringWithFormat:@"Stay Inn Airport South"];
    hotelEvent.toCity = firstEvent.toCity;
    hotelEvent.startDate = firstEvent.startDate;
    hotelEvent.eventType = [NSNumber numberWithInteger: EventTypeHotel];
    
    Trip *firstHotelEvent = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
    firstHotelEvent.defaultColor = firstTrip.defaultColor;
    firstHotelEvent.toCityDepartureCity = firstEvent.toCity;
    firstHotelEvent.toCityDestinationCity = firstEvent.toCity;
    firstHotelEvent.startDate = firstEvent.startDate; //one day before first event
    firstHotelEvent.endDate = firstEvent.endDate;
    firstHotelEvent.toEvent = hotelEvent;
    randomPrice = arc4random()%200+200;
    self.totalPrice += randomPrice;
    firstHotelEvent.price = [NSNumber numberWithInteger:randomPrice];
    firstHotelEvent.toItinerary = _itinerary;
    
    if ([[DataManager sharedInstance] saveTrip:firstHotelEvent
                                       context:self.managedObjectContext]) {
        _itinerary.date = firstTripWithEvent.startDate;
        _itinerary.title = [NSString stringWithFormat:NSLocalizedString(@"Trip to %@", nil), firstEvent.toCity.cityName];
    }
    
    Event *lastEvent = (Event *)[events lastObject];
    Trip *lastTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
    lastTrip.toCityDepartureCity = lastEvent.toCity;
    lastTrip.toCityDestinationCity = departureCity;
    lastTrip.startDate = [lastEvent.startDate dateAfterOneDay]; //one day before first event
    lastTrip.endDate = [lastEvent.endDate dateAfterOneDay];
    lastTrip.toEvent = nil;
    lastTrip.toItinerary = _itinerary;
    randomPrice = arc4random()%500+200;
    self.totalPrice += randomPrice;
    lastTrip.price = [NSNumber numberWithInteger:randomPrice];
    [[DataManager sharedInstance] saveTrip:lastTrip
                                   context:self.managedObjectContext];
    
    if ([[firstEvent.objectID URIRepresentation] isEqual:[lastEvent.objectID URIRepresentation]]) {
        Event *event = (Event *)[events lastObject];
        Trip *newTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        newTrip.toCityDepartureCity = event.toCity;
        newTrip.toCityDestinationCity = event.toCity;
        newTrip.startDate = event.startDate;
        newTrip.endDate = event.endDate;
        newTrip.toEvent = event;
        newTrip.toItinerary = _itinerary;
        [[DataManager sharedInstance] saveTrip:newTrip
                                       context:self.managedObjectContext];
        
        [self hideActivityIndicator];
        return;
    }
    
    for (NSInteger i = 1; i < [events count]; i++) {
        Event *previousEvent = (Event *)[events objectAtIndex:i-1];
        Event *currentEvent = (Event *)[events objectAtIndex:i];
        
        Trip *newTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        newTrip.toCityDepartureCity = previousEvent.toCity;
        newTrip.toCityDestinationCity = currentEvent.toCity;
        newTrip.startDate = previousEvent.endDate;
        newTrip.endDate = (i + 1 == [events count]) ? lastEvent.endDate : [currentEvent.startDate dateBeforeOneDay];
        newTrip.toEvent = (i + 1 == [events count]) ? lastEvent : currentEvent;
        newTrip.toItinerary = _itinerary;
        [[DataManager sharedInstance] saveTrip:newTrip
                                       context:self.managedObjectContext];
        
        if (![[previousEvent.toCity.cityName lowercaseString] isEqualToString:[currentEvent.toCity.cityName lowercaseString]]) {
            // Add flight objects here
        }
    }
    
    
    if (![[departureCity.cityName lowercaseString] isEqualToString:[firstEvent.toCity.cityName lowercaseString]]) {
        // Add flight objects here
    }
    
    if (![[departureCity.cityName lowercaseString] isEqualToString:[lastEvent.toCity.cityName lowercaseString]]) {
        // Add flight objects here
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"Total: $%d", self.totalPrice];
    [self hideActivityIndicator];
    [[TripManager sharedManager] setTripStage:TripStagePlanTrip];
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
        trip.endDate = self.currentDateRange.endDay.date; // Trip's endDate has to be equal to actually selected end day
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

    if (self.currentDateRange) {
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
        trip.endDate = self.originalDateRange.endDay.date; // Trip's endDate has to be equal to actually selected end day
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

- (IBAction)confirmTripButtonTapAction:(id)sender
{
    [self showActivityIndicatorWithText:NSLocalizedString(@"Booking your trip...\n\nPlease feel free to close the app. \nThis might take a while.", nil)];
    
    [[TripManager sharedManager] setTripStage:TripStageBookTrip];
    
    if ([[DataManager sharedInstance] saveItinerary:_itinerary context:self.managedObjectContext]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
}


#pragma mark - UITableView Delegate
- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    cell.eventTitleLabel.text = event.title;
    if ([event.eventType integerValue] == EventTypeHotel) {
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", [trip.price integerValue]];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon"]];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else{
        cell.priceLabel.text = @"";
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"eventIcon"]];
        cell.contentView.backgroundColor = UIColorFromRGB(0xF4F5F8);
    }
    if ([event.allDay boolValue]) {
        cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        cell.eventTimeLabel.text = [formatter stringFromDate:event ? event.startDate : trip.startDate];
    }
    
    if (!event) {
        //flight
        cell.eventTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flight to %@", nil), trip.toCityDestinationCity.cityName];
        cell.eventLocationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"5h\tnon-stop\tAirCanada", nil)];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", [trip.price integerValue]];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon"]];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        if ([event.location length] > 0) {
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
        }
        else if([event.toCity.cityName length] > 0){
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
        }
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                // TODO: Remove flights/hotel/rental car events (Set cascade delete rule for them)
                if ([[DataManager sharedInstance] deleteItineray:_itinerary
                                                         context:self.managedObjectContext]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
                break;
            }
            default:
                break;
        }
    }
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

#pragma mark - NSFetchedResultController configuration

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@ AND toItinerary = %@", [MockManager userid], _itinerary];
}
@end
