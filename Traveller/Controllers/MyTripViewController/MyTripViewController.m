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
