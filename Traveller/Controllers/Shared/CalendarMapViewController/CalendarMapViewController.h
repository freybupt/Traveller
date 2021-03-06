//
//  CalendarMapViewController.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Mapkit/MapKit.h>
#import "TripViewController.h"
#import "CalendarColorManager.h"
#import "CalendarView.h"
#import "Checkbox.h"
#import "DestinationPanelView.h"
#import "DSLCalendarView.h"
#import "DSLCalendarRange+Trip.h"

static CGFloat kUIAnimationDuration = 0.3f;
static CGFloat kMyScheduleYCoordinate = 320.0f;
static CGFloat kNavigationBarHeight = 44.0f;

@interface CalendarMapViewController : TripViewController<DSLCalendarViewDelegate>

//Customized Calendar/Map View
@property (nonatomic, weak) IBOutlet CalendarView *calendarView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, weak) IBOutlet UIView *myScheduleView;
@property (nonatomic, weak) IBOutlet UIView *myScheduleHeaderView;
@property (nonatomic, weak) IBOutlet UILabel *myScheduleTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *showCalendarButton;
@property (nonatomic, weak) IBOutlet UIButton *showMapButton;

//My schedule table components
@property (nonatomic, weak) IBOutlet UIButton *expandButton;
@property (nonatomic, assign) BOOL isScheduleExpanded;

//Destination panel view
@property (nonatomic, weak) IBOutlet DestinationPanelView *destinationPanelView;
@property (nonatomic, strong) DSLCalendarRange *currentDateRange;
@property (nonatomic, strong) DSLCalendarRange *originalDateRange;

//Object ID for active trip
@property (nonatomic, strong) NSManagedObjectID *objectID;

- (IBAction)showDestinationPanel:(id)sender;
- (IBAction)hideDestinationPanel:(id)sender;
- (IBAction)showMapview:(id)sender;
- (IBAction)showCalendarView:(id)sender;
- (IBAction)adjustScheduleView:(id)sender;
- (IBAction)editMySchedule:(id)sender;

- (void)getTripCityColorDictionary;
- (NSArray *)getActiveTripByDateRange:(DSLCalendarRange *)dateRange;
@end
