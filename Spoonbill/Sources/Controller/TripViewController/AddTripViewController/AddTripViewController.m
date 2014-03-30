//
//  AddTripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddTripViewController.h"
#import "AddTripTableViewCell.h"

#define ADDTRIP_TABLEVIEWCELL_IDENTIFIER @"AddTripTableViewCellIdentifier"
#define TRIP_TITLE_TEXTFIELD_PLACEHOLDER @"Please enter a trip title here..."

typedef NS_ENUM(NSInteger, AddTripTableSection) {
    AddTripTableSectionDetail,
    AddTripTableSectionEvent,
    AddTripTableSectionCount
};

typedef NS_ENUM(NSInteger, DetailTableRow) {
    DetailTableRowTitle,
    DetailTableRowDepartureCity,
    DetailTableRowDestinationCity,
    DetailTableRowStartDate,
    DetailTableRowEndDate,
    DetailTableRowRoundTrip,
    DetailTableRowDefaultColor,
    DetailTableRowCount
};

typedef NS_ENUM(NSInteger, EventTableRow) {
    EventTableRowAdd,
    EventTableRowCount
};

@interface AddTripViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSArray *detailTitles;
@end

@implementation AddTripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add Trip", nil);
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(backButtonTapAction:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(saveButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        _managedObjectContext = [NSManagedObjectContext new];
        _managedObjectContext.undoManager = nil;
        _managedObjectContext.persistentStoreCoordinator = [[TripManager sharedInstance] persistentStoreCoordinator];
        
        _events = [NSMutableArray new];
        _detailTitles = [self defaultDetailTitles];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView registerClass:[AddTripTableViewCell class]
       forCellReuseIdentifier:ADDTRIP_TABLEVIEWCELL_IDENTIFIER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

#pragma mark - Button tap action
- (IBAction)backButtonTapAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)saveButtonTapAction:(id)sender
{
    /*
    if ([[TripManager sharedInstance] getCityWithCityName:[_detailTitles objectAtIndex:DetailTableRowCity]
                                                  context:_managedObjectContext]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"The city item has been saved before", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([[TripManager sharedInstance] AddTripWithDictionary:[self cityDictionaryWithArray:_detailTitles]
                                                    context:_managedObjectContext]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when inserting a city item", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    */
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return AddTripTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == AddTripTableSectionDetail) ? DetailTableRowCount : EventTableRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADDTRIP_TABLEVIEWCELL_IDENTIFIER
                                                                 forIndexPath:indexPath];
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(AddTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AddTripTableSectionDetail:{
            if (indexPath.row == DetailTableRowTitle) {
                cell.textField.hidden = NO;
                cell.textField.placeholder = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.textField.tag = indexPath.row;
                cell.textField.delegate = self;
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if (indexPath.row == DetailTableRowRoundTrip) {
                cell.toggle.hidden = NO;
                cell.textLabel.text = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.textLabel.text = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }break;
        case AddTripTableSectionEvent:
            cell.textField.hidden = YES;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", NSLocalizedString(@"Events", nil), [NSNumber numberWithInteger:[_events count]]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableView default data
/*
- (NSArray *)cellTitles
{
    return @[_detailTitles];
}
*/
- (NSArray *)defaultDetailTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:DetailTableRowCount];
    for (NSUInteger idx = 0; idx < DetailTableRowCount; idx++) {
        switch (idx) {
            case DetailTableRowTitle:
                [mArray insertObject:TRIP_TITLE_TEXTFIELD_PLACEHOLDER atIndex:DetailTableRowTitle];
                break;
            case DetailTableRowDepartureCity:
                [mArray insertObject:@"Departure City" atIndex:DetailTableRowDepartureCity];
                break;
            case DetailTableRowDestinationCity:
                [mArray insertObject:@"Destination City" atIndex:DetailTableRowDestinationCity];
                break;
            case DetailTableRowStartDate:
                [mArray insertObject:@"Start Date" atIndex:DetailTableRowStartDate];
                break;
            case DetailTableRowEndDate:
                [mArray insertObject:@"End Date" atIndex:DetailTableRowEndDate];
                break;
            case DetailTableRowRoundTrip:
                [mArray insertObject:@"Round Trp" atIndex:DetailTableRowRoundTrip];
                break;
            case DetailTableRowDefaultColor:
                [mArray insertObject:@"Default Color" atIndex:DetailTableRowDefaultColor];
                break;
        }
    }
    return mArray;
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [textField.placeholder isEqualToString:NSLocalizedString(TRIP_TITLE_TEXTFIELD_PLACEHOLDER, nil)];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [textField.placeholder isEqualToString:NSLocalizedString(TRIP_TITLE_TEXTFIELD_PLACEHOLDER, nil)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] > 0) {

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
