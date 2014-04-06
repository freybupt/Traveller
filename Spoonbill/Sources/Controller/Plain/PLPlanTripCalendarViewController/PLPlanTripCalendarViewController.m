//
//  PLPlanTripCalendarViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripCalendarViewController.h"
#import "DSLCalendarView.h"

typedef NS_ENUM(NSInteger, PlanTripTableSection) {
    PlanTripTableSectionCalendarMapView,
    PlanTripTableSectionEventList,
    PlanTripTableSectionCount
};

@interface PLPlanTripCalendarViewController ()<DSLCalendarViewDelegate>
@property (nonatomic, weak) IBOutlet DSLCalendarView *calendarView;
@end

@implementation PLPlanTripCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(toggleCalendarMapViewButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
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

#pragma mark - Button tap action
- (IBAction)toggleCalendarMapViewButtonTapAction:(id)sender
{
    UIBarButtonItem *rightBarButtonItem = (UIBarButtonItem *)sender;
    [UIView transitionWithView:self.tableView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           _calendarView.alpha = (self.tableView.contentInset.top < _calendarView.frame.size.height) ? 1.0f : 0.0f;
                           rightBarButtonItem.title = (self.tableView.contentInset.top < _calendarView.frame.size.height) ? NSLocalizedString(@"Close", nil) : NSLocalizedString(@"Open", nil);
                           [self.tableView setContentInset:UIEdgeInsetsMake((self.tableView.contentInset.top < _calendarView.frame.size.height) ? _calendarView.frame.size.height : 0.0f, 0.0f, 0.0f, 0.0f)];
    } completion:^(BOOL finished) {
        if (finished) {
            [self.tableView setContentOffset:CGPointMake(0.0f, (self.tableView.contentInset.top < _calendarView.frame.size.height) ? 0.0f : -_calendarView.frame.size.height)
                                    animated:NO];
        }
    }];
}

#pragma mark - UITableView configuration
- (void)setTableView
{ 
    NSUInteger flags = NSCalendarCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:[NSDate date]];
    
    [_calendarView setVisibleMonth:components animated:NO];
    _calendarView.delegate = self;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(_calendarView.frame.size.height, 0.0f, 0.0f, 0.0f)];
}

#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %d/%d - %d/%d", range.startDay.day, range.startDay.month, range.endDay.day, range.endDay.month);
    }
    else {
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
    /* Adjust table's content inset according to the height of calendar view */
    [UIView transitionWithView:self.tableView
                      duration:duration
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           [self.tableView setContentInset:UIEdgeInsetsMake(calendarView.frame.size.height, 0.0f, 0.0f, 0.0f)];
                       } completion:^(BOOL finished) {
                           if (finished) {
                               [self.tableView setContentOffset:CGPointMake(0.0f, -calendarView.frame.size.height)
                                                       animated:NO];
                           }
                       }];
}

- (void)calendarView:(DSLCalendarView *)calendarView
    didChangeToVisibleMonth:(NSDateComponents *)month
{
    NSLog(@"Now showing %@", month);
}

- (BOOL)day:(NSDateComponents*)day1
isBeforeDay:(NSDateComponents*)day2
{
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}

@end
