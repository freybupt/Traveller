//
//  EventDetailViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "EventDetailViewController.h"
#import "CityMapViewController.h"
#import "AddCityViewController.h"

#define EVENTDETAIL_TABLEVIEWCELL_IDENTIFIER @"EventDetailTableViewCellIdentifier"

typedef NS_ENUM(NSInteger, EventInfoTableRow) {
    EventInfoTableRowTitle,
    EventInfoTableRowEventIdentifier,
    EventInfoTableRowLocation,
    EventInfoTableRowStartDate,
    EventInfoTableRowEndDate,
    EventInfoTableRowAllDay,
    EventInfoTableRowURL,
    EventInfoTableRowNotes,
    EventInfoTableRowCount
};

@interface EventDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event *event;
@end

@implementation EventDetailViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withEvent:(Event *)event
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _event = event;
        
        _managedObjectContext = [NSManagedObjectContext new];
        _managedObjectContext.undoManager = nil;
        _managedObjectContext.persistentStoreCoordinator = [[TripManager sharedInstance] persistentStoreCoordinator];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Event Detail", nil);
    
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:EVENTDETAIL_TABLEVIEWCELL_IDENTIFIER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)cityMapButtonTapAction:(City *)city
{
    if (!city) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Core Data", nil)
                                                            message:NSLocalizedString(@"The city item is not in your local database", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Add City", nil), NSLocalizedString(@"OK", nil), nil];
        [alertView show];
        return;
    }
    
    CityMapViewController *vc = [[CityMapViewController alloc] initWithNibName:@"CityMapViewController"
                                                                        bundle:nil
                                                                      withCity:city];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addCityButtonTapAction:(id)sender
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add City", nil)
                                                            message:NSLocalizedString(@"Internet is necessary to add city", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    AddCityViewController *vc = [[AddCityViewController alloc] initWithNibName:@"AddCityViewController"
                                                                        bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self addCityButtonTapAction:nil];
    }
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return EventInfoTableRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENTDETAIL_TABLEVIEWCELL_IDENTIFIER
                                                            forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case EventInfoTableRowTitle:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Title: %@", nil), _event.title];
            break;
        case EventInfoTableRowEventIdentifier:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Identifier: %@", nil), _event.eventIdentifier];
            break;
        case EventInfoTableRowLocation:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Location: %@", nil), _event.location];
            break;
        case EventInfoTableRowStartDate:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Start: %@", nil), [_event.startDate translatedTime]];
            break;
        case EventInfoTableRowEndDate:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"End: %@", nil), [_event.endDate translatedTime]];
            break;
        case EventInfoTableRowAllDay:
            cell.textLabel.text = [_event.allDay boolValue] ? NSLocalizedString(@"All Day: YES", nil) : NSLocalizedString(@"All Day: NO", nil);
            break;
        case EventInfoTableRowURL:
            cell.textLabel.text = [_event.url isStringObject] ? [NSString stringWithFormat:NSLocalizedString(@"URL: %@", nil), _event.url] : @"";
            break;
        case EventInfoTableRowNotes:
            cell.textLabel.text = [_event.notes isStringObject] ? [NSString stringWithFormat:NSLocalizedString(@"Notes: %@", nil), _event.notes] : @"";
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    City *city = [[TripManager sharedInstance] getCityWithCityName:_event.location
                                                           context:_managedObjectContext];
    switch (indexPath.row) {
        case EventInfoTableRowLocation:{
            [self cityMapButtonTapAction:city];
        }break;
    }
}
@end
