//
//  PLPlanTripCalendarViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripCalendarViewController.h"
#import "PLPlanTripTableViewCell.h"

#define PLANTRIPCALENDAR_HEADER_REUSEIDENTIFIER @"PLPlanTripCalendarTableViewSectionHeaderViewIdentifier"

typedef NS_ENUM(NSInteger, PlanTripTableSection) {
    PlanTripTableSectionCalendarMapView,
    PlanTripTableSectionEventList,
    PlanTripTableSectionCount
};

@interface PLPlanTripCalendarViewController ()

@end

@implementation PLPlanTripCalendarViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)hideCalendarMapViewButtonTapAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [UIView transitionWithView:self.tableView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           _calendarView.alpha = (self.tableView.contentInset.top < _calendarView.frame.size.height) ? 1.0f : 0.0f;
                           self.tableView.contentInset = UIEdgeInsetsMake((self.tableView.contentInset.top < _calendarView.frame.size.height) ? _calendarView.frame.size.height : 0.0f, 0.0f, 0.0f, 0.0f);
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
    NSUInteger flags = NSCalendarCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:[NSDate date]];
    
    [_calendarView setVisibleMonth:components animated:NO];
    _calendarView.delegate = self;
    
    [self drawCalendarDayViewForEvent];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(_calendarView.frame.size.height, 0.0f, 0.0f, 0.0f)];
    [self.tableView registerClass:[PLPlanTripCalendarHeaderFooterView class]
        forHeaderFooterViewReuseIdentifier:[self tableHeaderReuseIdentifier]];
}

- (NSString *)tableHeaderReuseIdentifier
{
    return PLANTRIPCALENDAR_HEADER_REUSEIDENTIFIER;
}

#pragma mark - Table view data source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"MY SCHEDULE", nil);
    }
    
    NSString *dateString = [[[self.fetchedResultsController sections] objectAtIndex:section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER] name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // Raw Date String -> NSDate
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    // NSDate -> Formatted Date String
    [formatter setDateFormat:@"EEE, MMM dd"];
    NSString *formattedDateString = [formatter stringFromDate:date];
    
    return formattedDateString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return PLANTRIPCALENDAR_HEADERFOOTER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PLPlanTripCalendarHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self tableHeaderReuseIdentifier]];
    
    [sectionHeaderView.middleButton addTarget:self
                                 action:@selector(hideCalendarMapViewButtonTapAction:)
                       forControlEvents:UIControlEventTouchUpInside];
    sectionHeaderView.middleButton.hidden = (section != SECTIONHEADER_FOR_TOOLCONTROL_POINTER - 1);
    
    [sectionHeaderView.rightButton addTarget:self
                                      action:@selector(addEventButtonTapAction:)
                            forControlEvents:UIControlEventTouchUpInside];
    sectionHeaderView.rightButton.hidden = (section != SECTIONHEADER_FOR_TOOLCONTROL_POINTER - 1);
    
    return sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if ([[self.fetchedResultsController sections] count] > 0 &&
        section !=0 ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (void)configureCell:(PLPlanTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER]; /* Translated indexPath */
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.timeLabel.text = [event.allDay boolValue] ? NSLocalizedString(@"all-day", nil) : [event.startDate hourTime];
    cell.titleLabel.text = event.title;
    cell.locationLabel.text = event.location;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER]; /* Translated indexPath */
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self eventDetailButtonTapAction:event];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER]; /* Translated indexPath */
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self eventDetailButtonTapAction:event];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - SECTIONHEADER_FOR_TOOLCONTROL_POINTER]; /* Translated indexPath */
        Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TripManagerOperationDidDeleteEventNotification
                                                                object:event
                                                              userInfo:nil];
        });
    }
}

#pragma mark - DSLCalendarViewDelegate methods
- (void)calendarView:(DSLCalendarView *)calendarView
      didSelectRange:(DSLCalendarRange *)range
{
    if (range != nil) {
        NSLog( @"Selected %@/%@ - %@/%@", [NSNumber numberWithInteger:range.startDay.day],
              [NSNumber numberWithInteger:range.startDay.month],
              [NSNumber numberWithInteger:range.endDay.day],
              [NSNumber numberWithInteger:range.endDay.month]);
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
    [self drawCalendarDayViewForEvent];
}

- (BOOL)day:(NSDateComponents*)day1
isBeforeDay:(NSDateComponents*)day2
{
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Overwrite to disable the method from parent class (PLPlanTripViewController)
}

#pragma mark - NSFetchedResultsController delegate
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + SECTIONHEADER_FOR_TOOLCONTROL_POINTER]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + SECTIONHEADER_FOR_TOOLCONTROL_POINTER]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + SECTIONHEADER_FOR_TOOLCONTROL_POINTER];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + SECTIONHEADER_FOR_TOOLCONTROL_POINTER];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + SECTIONHEADER_FOR_TOOLCONTROL_POINTER];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView reloadData];
            break;
    }
}

#pragma mark - DSLCalendarDayView helpers
- (void)drawCalendarDayViewForEvent
{
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        
        NSUInteger flags = NSCalendarCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:flags fromDate:event.startDate];
        
        DSLCalendarMonthView *calendarMonthView = (DSLCalendarMonthView *)[_calendarView cachedOrCreatedMonthViewForMonth:_calendarView.visibleMonth];
        [[calendarMonthView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[PLPlanTripCalendarDayView class]]) {
                PLPlanTripCalendarDayView *dayView = (PLPlanTripCalendarDayView *)obj;
                if (dayView.day.year == components.year &&
                    dayView.day.month == components.month &&
                    dayView.day.day == components.day) {
                    dayView.tag = components.year * 10000 + components.month * 100 + components.day;
                    [dayView setNeedsDisplay];
                }
            }
        }];
    }];
}
@end
