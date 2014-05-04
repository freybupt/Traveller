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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

#pragma mark - UI IBAction
- (IBAction)calculateTrip:(id)sender
{
    NSArray *events = [[DataManager sharedInstance] getEventWithSelected:YES
                                                                 context:self.managedObjectContext];
    if ([events count] == 0) {
        [self hideActivityIndicator];
        return;
    }

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
    firstTrip.toItinerary = _itinerary;
    if ([[DataManager sharedInstance] saveTrip:firstTrip
                                       context:self.managedObjectContext]) {
        _itinerary.date = firstTrip.startDate;
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
    
    if ([[DataManager sharedInstance] saveItinerary:_itinerary context:self.managedObjectContext]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
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
