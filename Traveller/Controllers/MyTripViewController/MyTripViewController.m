//
//  MyTripViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-02.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyTripViewController.h"

@interface MyTripViewController ()
@property (nonatomic, strong) Itinerary *itinerary;
@end

@implementation MyTripViewController

- (void)awakeFromNib
{
    self.navigationItem.rightBarButtonItem = nil;
    
    NSArray *array = [[DataManager sharedInstance] getItineraryWithUserid:[MockManager userid]
                                                                  context:self.managedObjectContext];
    if ([array count] > 0) {
        _itinerary = [array objectAtIndex:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getTripCityColorDictionary];
    [self hideActivityIndicator];
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

#pragma mark - UITableViewDelegate
- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    cell.eventTitleLabel.text = event.title;
    if ([event.eventType integerValue] == EventTypeHotel) {
        //hotel
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins from airport", arc4random()%40+10];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon"]];
        [cell.actionButton setTitle:@"Call Hotel" forState:UIControlStateNormal];
    }
    else{
        //calendar events
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins drive from hotel", arc4random()%5+2];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"eventIcon"]];
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
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon"]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - DSLCalendarViewDelegate methods
- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
    }
    else {
        NSLog( @"No selection" );
    }
}

#pragma mark - NSFetchedResultController configuration

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@ AND toItinerary = %@", [MockManager userid], _itinerary];
}
@end
