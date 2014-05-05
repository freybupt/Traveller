//
//  ItineraryTripViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ItineraryTripViewController.h"
#import "ItineraryTripTableViewCell.h"

#define ITINERARYTRIP_TABLEVIEWCELL_IDENTIFIER @"ItineraryTripTableCellIdentifier"

@interface ItineraryTripViewController ()
@property (nonatomic, strong) Itinerary *itinerary;
@end

@implementation ItineraryTripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            itinerary:(Itinerary *)itinerary
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TRIP", nil);
        _itinerary = itinerary;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - NSFetchedResultController configuration

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@ AND toItinerary = %@", [MockManager userid], _itinerary];
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    // Overriding to disable the method in superclass CDTableViewController
}

- (NSString *)tableCellReuseIdentifier
{
    return ITINERARYTRIP_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - UITableView delegate and datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItineraryTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ItineraryTripTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(ItineraryTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    cell.eventTitleLabel.text = event.title;
    if ([event.eventType integerValue] == EventTypeHotel) {
        //hotel
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins from airport", arc4random()%40+10];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon.png"]];
        [cell.actionButton setTitle:@"Call Hotel" forState:UIControlStateNormal];
    }
    else{
        //calendar events
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins drive from hotel", arc4random()%5+2];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"eventIcon.png"]];
        [cell setBackgroundColor:[UIColor lightTextColor]];
        [cell.actionButton setTitle:@"Contact" forState:UIControlStateNormal];
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
        cell.priceLabel.text = [NSString stringWithFormat:@"on-time"];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon.png"]];
        [cell.actionButton setTitle:@"Check-in" forState:UIControlStateNormal];
    } else {
        if ([event.location length] > 0) {
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
        }
        else if([event.toCity.cityName length] > 0){
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
        }
    }
}

@end
