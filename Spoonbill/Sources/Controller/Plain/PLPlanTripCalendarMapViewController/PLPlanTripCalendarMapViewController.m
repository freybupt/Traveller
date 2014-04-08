//
//  PLPlanTripCalendarMapViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-08.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PLPlanTripCalendarMapViewController.h"

@interface PLPlanTripCalendarMapViewController ()
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end

@implementation PLPlanTripCalendarMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *rightButton = [self newRightButton];
        [rightButton addTarget:self
                        action:@selector(toggleCalendarMapViewButtonTapAction:)
              forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Initial map/calendar property setup */
    _mapView.frame = self.calendarView.frame;
    self.calendarView.hidden = YES;
    
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

#pragma mark - Button tap action
- (IBAction)toggleCalendarMapViewButtonTapAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    _mapView.hidden = !_mapView.hidden;
    self.calendarView.hidden = !self.calendarView.hidden;
    
    if (self.tableView.contentInset.top < self.calendarView.frame.size.height) {
        PLPlanTripCalendarHeaderFooterView *headerView = (PLPlanTripCalendarHeaderFooterView *)[self.tableView headerViewForSection:SECTIONHEADER_FOR_TOOLCONTROL_POINTER - 1];
        [self hideCalendarMapViewButtonTapAction:headerView.middleButton];
    }
}

- (IBAction)hideCalendarMapViewButtonTapAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [UIView transitionWithView:self.tableView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           self.calendarView.alpha = (self.tableView.contentInset.top < self.calendarView.frame.size.height) ? 1.0f : 0.0f;
                           _mapView.alpha = (self.tableView.contentInset.top < self.calendarView.frame.size.height) ? 1.0f : 0.0f;
                           self.tableView.contentInset = UIEdgeInsetsMake((self.tableView.contentInset.top < self.calendarView.frame.size.height) ? self.calendarView.frame.size.height : 0.0f, 0.0f, 0.0f, 0.0f);
                       } completion:^(BOOL finished) {
                           if (finished) {
                               [self.tableView setContentOffset:CGPointMake(0.0f, (self.tableView.contentInset.top < self.calendarView.frame.size.height) ? 0.0f : -self.calendarView.frame.size.height)
                                                       animated:NO];
                           }
                       }];
}

#pragma mark - Table view data source & delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self setForMapViewLayout];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER]; /* Translated indexPath */
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    City *city = event.toCity;
    
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake([city.latitude floatValue], [city.longitude floatValue]);
    region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                       DEFAULT_MAP_COORDINATE_SPAN * _mapView.frame.size.height/_mapView.frame.size.width);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView setRegion:region animated:YES];
    });
}

#pragma mark - DSLCalendarViewDelegate methods
- (void)calendarView:(DSLCalendarView *)calendarView
willChangeToVisibleMonth:(NSDateComponents *)month
            duration:(NSTimeInterval)duration
{
    /* Adjust table's content inset according to the height of calendar view */
    [UIView transitionWithView:self.tableView
                      duration:duration
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           [self.tableView setContentInset:UIEdgeInsetsMake(calendarView.frame.size.height, 0.0f, 0.0f, 0.0f)];
                       } completion:^(BOOL finished) {
                           if (finished) {
                               [self.tableView setContentOffset:CGPointMake(0.0f, -calendarView.frame.size.height)
                                                       animated:NO];
                               _mapView.frame = calendarView.frame;
                           }
                       }];
}

#pragma mark - Configuration
- (UIButton *)newRightButton;
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  25.0f,
                                                                  25.0f)];
    [button setImage:[UIImage imageNamed:@"calendar53"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"map35"] forState:UIControlStateSelected];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, -10.0f);
    
    return button;
}

#pragma mark - Layout
- (void)setForMapViewLayout
{
    if (self.tableView.contentInset.top < self.calendarView.frame.size.height) {
        PLPlanTripCalendarHeaderFooterView *headerView = (PLPlanTripCalendarHeaderFooterView *)[self.tableView headerViewForSection:SECTIONHEADER_FOR_TOOLCONTROL_POINTER - 1];
        [self hideCalendarMapViewButtonTapAction:headerView.middleButton];
    }
    
    if (_mapView.hidden &&
        [self.navigationItem.rightBarButtonItem.customView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
        [self toggleCalendarMapViewButtonTapAction:button];
    }
}
@end
