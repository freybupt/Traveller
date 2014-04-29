//
//  RootViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "RootViewController.h"

/* Stylish */
#import "ModalViewController.h"

/* Plain */
#import "PLPlanTripViewController.h"
#import "PLPlanTripCalendarViewController.h"
#import "PLPlanTripCalendarMapViewController.h"
#import "PLAutocompleteViewController.h"

/* Core Data */
#import "CityViewController.h"
#import "EventViewController.h"
#import "TripViewController.h"
#import "CarViewController.h"

#define ROOT_TABLEVIEWCELL_IDENTIFIER @"RootTableViewCellIdentifier"

typedef NS_ENUM(NSInteger, RootTableSection) {
    RootTableSectionStylish,
    RootTableSectionPlain,
    RootTableSectionCoreData,
    RootTableSectionCount
};

typedef NS_ENUM(NSInteger, StylishTableRow) {
    StylishTableRowModalView,
    StylishTableRowCount
};

typedef NS_ENUM(NSInteger, PlainTableRow) {
    PlainTableRowPlanTrip,
    PlainTableRowPlanTripCalendar,
    PlainTableRowPlanTripCalendarMap,
    PlainTableRowPlanAutocomplete,
    PlainTableRowCount
};

typedef NS_ENUM(NSInteger, CoreDataTableRow) {
    CoreDataTableRowCity,
    CoreDataTableRowEvent,
    CoreDataTableRowTrip,
    CoreDataTableRowCar,
    CoreDataTableRowCount
};

@interface RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Generate preset city if there is no any city object*/
    [MockManager sharedInstance];
    
    self.title = NSLocalizedString(@"Spoonbill", nil);
    
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:ROOT_TABLEVIEWCELL_IDENTIFIER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

#pragma mark - Button tap action
/* Stylish */
- (IBAction)modalViewButtonTapAction:(id)sender
{
    ModalViewController *vc = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

/* Plain */
- (IBAction)planTripButtonTapAction:(id)sender
{
    PLPlanTripViewController *vc = [[PLPlanTripViewController alloc] initWithNibName:@"PLPlanTripViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)planTripCalendarButtonTapAction:(id)sender
{
    PLPlanTripCalendarViewController *vc = [[PLPlanTripCalendarViewController alloc] initWithNibName:@"PLPlanTripCalendarViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)planTripCalendarMapButtonTapAction:(id)sender
{
    PLPlanTripCalendarMapViewController *vc = [[PLPlanTripCalendarMapViewController alloc] initWithNibName:@"PLPlanTripCalendarMapViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)autocompleteButtonTapAction:(id)sender
{
    PLAutocompleteViewController *vc = [[PLAutocompleteViewController alloc] initWithNibName:@"PLAutocompleteViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

/* Core Data */
- (IBAction)cityButtonTapAction:(id)sender
{
    CityViewController *vc = [[CityViewController alloc] initWithNibName:@"CityViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)eventButtonTapAction:(id)sender
{
    EventViewController *vc = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tripButtonTapAction:(id)sender
{
    TripViewController *vc = [[TripViewController alloc] initWithNibName:@"TripViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)carButtonTapAction:(id)sender
{
    CarViewController *vc = [[CarViewController alloc] initWithNibName:@"CarViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self cellTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString([[self headerTitles] objectAtIndex:section], nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self cellTitles] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ROOT_TABLEVIEWCELL_IDENTIFIER
                                                            forIndexPath:indexPath];
    
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = NSLocalizedString([[[self cellTitles] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case RootTableSectionStylish:
            [self tapStylishCellAtIndexPath:indexPath];
            break;
        case RootTableSectionPlain:
            [self tapPlainCellAtIndexPath:indexPath];
            break;
        case RootTableSectionCoreData:
            [self tapCoreDataCellAtIndexPath:indexPath];
            break;
    }
}

#pragma mark - UITableView tap action
- (void)tapStylishCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case StylishTableRowModalView:
            [self modalViewButtonTapAction:nil];
            break;
    }
}

- (void)tapPlainCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PlainTableRowPlanTrip:
            [self planTripButtonTapAction:nil];
            break;
        case PlainTableRowPlanTripCalendar:
            [self planTripCalendarButtonTapAction:nil];
            break;
        case PlainTableRowPlanTripCalendarMap:
            [self planTripCalendarMapButtonTapAction:nil];
            break;
        case PlainTableRowPlanAutocomplete:
            [self autocompleteButtonTapAction:nil];
            break;
    }
}

- (void)tapCoreDataCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CoreDataTableRowCity:
            [self cityButtonTapAction:nil];
            break;
        case CoreDataTableRowEvent:
            [self eventButtonTapAction:nil];
            break;
        case CoreDataTableRowTrip:
            [self tripButtonTapAction:nil];
            break;
        case CoreDataTableRowCar:
            [self carButtonTapAction:nil];
            break;
    }
}

#pragma mark - UITableView default data
- (NSArray *)headerTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:RootTableSectionCount];
    for (NSUInteger idx = 0; idx < RootTableSectionCount; idx++) {
        switch (idx) {
            case RootTableSectionStylish:
                [mArray insertObject:@"Stylish" atIndex:RootTableSectionStylish];
                break;
            case RootTableSectionPlain:
                [mArray insertObject:@"Plain" atIndex:RootTableSectionPlain];
                break;
            case RootTableSectionCoreData:
                [mArray insertObject:@"Core Data" atIndex:RootTableSectionCoreData];
                break;
        }
    }
    return mArray;
}

- (NSArray *)cellTitles
{
    return @[[self stylishCellTitles],
             [self plainCellTitles],
             [self coreDataCellTitles]];
}

- (NSArray *)stylishCellTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:StylishTableRowCount];
    for (NSUInteger idx = 0; idx < StylishTableRowCount; idx++) {
        switch (idx) {
            case StylishTableRowModalView:
                [mArray insertObject:@"Modal View" atIndex:StylishTableRowModalView];
                break;
        }
    }
    return mArray;
}

- (NSArray *)plainCellTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:PlainTableRowCount];
    for (NSUInteger idx = 0; idx < PlainTableRowCount; idx++) {
        switch (idx) {
            case PlainTableRowPlanTrip:
                [mArray insertObject:@"Plan Trip" atIndex:PlainTableRowPlanTrip];
                break;
            case PlainTableRowPlanTripCalendar:
                [mArray insertObject:@"Plan Trip + Calendar" atIndex:PlainTableRowPlanTripCalendar];
                break;
            case PlainTableRowPlanTripCalendarMap:
                [mArray insertObject:@"Plan Trip + Calendar + Map" atIndex:PlainTableRowPlanTripCalendarMap];
                break;
            case PlainTableRowPlanAutocomplete:
                [mArray insertObject:@"Autocomplete" atIndex:PlainTableRowPlanAutocomplete];
                break;
        }
    }
    return mArray;
}

- (NSArray *)coreDataCellTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:CoreDataTableRowCount];
    for (NSUInteger idx = 0; idx < CoreDataTableRowCount; idx++) {
        switch (idx) {
            case CoreDataTableRowCity:
                [mArray insertObject:@"City" atIndex:CoreDataTableRowCity];
                break;
            case CoreDataTableRowEvent:
                [mArray insertObject:@"Event" atIndex:CoreDataTableRowEvent];
                break;
            case CoreDataTableRowTrip:
                [mArray insertObject:@"Trip" atIndex:CoreDataTableRowTrip];
                break;
            case CoreDataTableRowCar:
                [mArray insertObject:@"Car" atIndex:CoreDataTableRowCar];
                break;
        }
    }
    return mArray;
}
@end
