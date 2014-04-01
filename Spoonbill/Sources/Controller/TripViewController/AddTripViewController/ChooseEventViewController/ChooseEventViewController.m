//
//  ChooseEventViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ChooseEventViewController.h"
#import "ChooseEventTableViewCell.h"

#define CHOOSEEVENT_TABLEVIEWCELL_IDENTIFIER @"ChooseEventTableCellIdentifier"

NSString * const TripOperationDidUpdateTripEventsNotification = @"com.spoonbill.tripviewcontroller.operation.update.tripevents";

@interface ChooseEventViewController ()
@property (nonatomic, strong) Trip *trip;
@end

@implementation ChooseEventViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                 trip:(Trip *)trip
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Choose Event", nil);
        _trip = (Trip *)[self.managedObjectContext objectWithID:trip.objectID];;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)addRemoveButtonTapAction:(UIButton *)button
{
    button.selected = !button.selected;
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TripOperationDidUpdateTripEventsNotification
                                                            object:event
                                                          userInfo:nil];
    });
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    [self.tableView registerClass:[ChooseEventTableViewCell class]
           forCellReuseIdentifier:[self tableCellReuseIdentifier]];
}

- (NSString *)tableCellReuseIdentifier
{
    return CHOOSEEVENT_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - Table view data source & delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]];
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ChooseEventTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", event.title, event.location];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [event.startDate relativeTime], [event.endDate relativeTime]];

    cell.button.tag = indexPath.row;
    cell.button.selected = [_trip.toEvent containsObject:event];
    [cell.button addTarget:self
                    action:@selector(addRemoveButtonTapAction:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
@end
