//
//  PLPlanTripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripViewController.h"
#import "PLPlanTripTableViewCell.h"

#define PLANTRIP_TABLEVIEWCELL_IDENTIFIER @"PlanTripTableCellIdentifier"
#define PLANTRIP_SECTION_HEADER_HEIGHT 25.0f

@interface PLPlanTripViewController ()

@end

@implementation PLPlanTripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Plan Trip", nil);
        self.navigationItem.rightBarButtonItem = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView configuration
- (NSString *)tableCellReuseIdentifier
{
    return PLANTRIP_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - NSFetchedResultController configuration
- (NSString *)sectionNameKeyPath
{
    return @"startDate";
}

#pragma mark - Table view data source & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PLANTRIP_TABLEVIEWCELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return PLANTRIP_SECTION_HEADER_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // Raw Date String -> NSDate
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    // NSDate -> Formatted Date String
    [formatter setDateFormat:@"EEE, MMM dd"];
    NSString *formattedDateString = [formatter stringFromDate:date];
    
    return formattedDateString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLPlanTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]];
    if (!cell) {
        cell = [[PLPlanTripTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:[self tableCellReuseIdentifier]];
    }
    
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PLPlanTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.timeLabel.text = [event.allDay boolValue] ? NSLocalizedString(@"all-day", nil) : [event.startDate hourTime];
    cell.titleLabel.text = event.title;
    cell.locationLabel.text = event.location;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = PLANTRIP_SECTION_HEADER_HEIGHT;
    if (scrollView.contentOffset.y <= sectionHeaderHeight &&
        scrollView.contentOffset.y >= 0.0f) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0.0f, 0.0f, 0.0f);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0.0f, 0.0f, 0.0f);
    }
}
@end