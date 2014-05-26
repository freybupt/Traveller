//
//  MyTripViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-02.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyTripViewController.h"
#import "MyTripTableViewCell.h"

#define MYTRIP_TABLEVIEWCELL_IDENTIFIER @"MyTripTableCellIdentifier"

static NSInteger kEventCellHeight = 80;
static NSInteger kFlightCellFullHeight = 400;
static NSInteger kHotelCellFullHeight = 300;

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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.tableView reloadData];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.expandedCellIndexPath]) {
        Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        Event *event = trip.toEvent;
        
        //expand list item
        if (!event) {
            //flight
            return kFlightCellFullHeight;
        }
        else if ([event.eventType integerValue] == EventTypeHotel) {
            //hotel
            return kHotelCellFullHeight;
        }
        else{
            //calendar event
            return kEventCellHeight;
        }
    }
    else{
        return kEventCellHeight;
    }
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    // Overriding to disable the method in superclass CDTableViewController
}

- (NSString *)tableCellReuseIdentifier
{
    return MYTRIP_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - UITableView delegate and datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyTripTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(MyTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    if ([event.eventType integerValue] == EventTypeHotel) {
        //hotel
        cell.flightDetail.hidden = YES;
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins from airport", arc4random()%40+10];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon"]];
        [cell.actionButton setTitle:@"Call Hotel" forState:UIControlStateNormal];
    }
    else{
        //calendar events
        cell.flightDetail.hidden = YES;
        cell.priceLabel.text = [NSString stringWithFormat:@"%d mins drive from hotel", arc4random()%5+2];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"eventIcon"]];
        [cell setBackgroundColor:[UIColor lightTextColor]];
        [cell.actionButton setTitle:@"Contact" forState:UIControlStateNormal];
    }
    
    cell.attributedLabel.attributedText = [MyTripTableViewCell attributedString:trip];
    if (!event) {
        //flight
        cell.flightDetail.hidden = ![indexPath isEqual:self.expandedCellIndexPath];
        cell.priceLabel.text = [NSString stringWithFormat:@"on-time"];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon"]];
        [cell.actionButton setTitle:@"Check-in" forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    if (self.isScheduleExpanded) {
        if ([indexPath isEqual:self.expandedCellIndexPath]) {
            self.expandedCellIndexPath = nil;
        }
        else{
            self.expandedCellIndexPath = indexPath;
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //expand list item
        if (!event) {
            //flight
        }
        else if ([event.eventType integerValue] == EventTypeHotel) {
            //hotel
        }
        else{
            //calendar event
            [self editEventButtonTapAction:event];
        }
    }
    else{
        //hightlight item in calendar or map
        /*
        if (!event) {
            //flight
            PlanTripViewController __weak *weakSelf = self;
            City *city = trip.toCityDestinationCity;
            MKCoordinateRegion region;
            region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
            region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                               DEFAULT_MAP_COORDINATE_SPAN * weakSelf.mapView.frame.size.height/weakSelf.mapView.frame.size.width);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mapView setRegion:region animated:YES];
            });
        }
        else{
            //update map
            PlanTripViewController __weak *weakSelf = self;
            City *city = event.toCity;
            MKCoordinateRegion region;
            region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
            region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                               DEFAULT_MAP_COORDINATE_SPAN * weakSelf.mapView.frame.size.height/weakSelf.mapView.frame.size.width);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mapView setRegion:region animated:YES];
            });
        }
        */
    }

    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
