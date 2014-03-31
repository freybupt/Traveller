//
//  AddTripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddTripViewController.h"
#import "AddTripTableViewCell.h"
#import "DepartureCityViewController.h"
#import "DestinationCityViewController.h"

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
    DetailTableRowStartDatePicker,
    DetailTableRowEndDate,
    DetailTableRowEndDatePicker,
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
@property (nonatomic, strong) Trip *trip;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *detailTitles;
@property (nonatomic, assign) BOOL hasStartDatePicker;
@property (nonatomic, assign) BOOL hasEndDatePicker;
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
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip"
                                                  inManagedObjectContext:_managedObjectContext];
        _trip = [[Trip alloc] initWithEntity:entity
              insertIntoManagedObjectContext:_managedObjectContext];
        
        // TODO: Remove the following part later.
        /* Default values for trip item */
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor]];
        _trip.defaultColor = colorData;
        _trip.uid = [MockManager userid];
        
        _events = [NSMutableArray new];
        _detailTitles = [[NSMutableArray alloc] initWithArray:[self defaultDetailTitles]];
        
        _hasStartDatePicker = NO;
        _hasEndDatePicker = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView registerClass:[AddTripTableViewCell class]
       forCellReuseIdentifier:ADDTRIP_TABLEVIEWCELL_IDENTIFIER];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleTapFrom:)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [_tableView addGestureRecognizer:tapGestureRecognizer];
    
    [self registerNotificationCenter];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterNotificationCenter];
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
    AddTripTableViewCell *cell = (AddTripTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:DetailTableRowTitle inSection:AddTripTableSectionDetail]];
    _trip.title = cell.textField.text;

    if ([[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (IBAction)departureCityButtonTapAction:(id)sender
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Depature City", nil)
                                                            message:NSLocalizedString(@"Internet is necessary to add departure city", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    DepartureCityViewController *vc = [[DepartureCityViewController alloc] initWithNibName:@"DepartureCityViewController"
                                                                              bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)destinationCityButtonTapAction:(id)sender
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Destination City", nil)
                                                            message:NSLocalizedString(@"Internet is necessary to add destination city", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    DestinationCityViewController *vc = [[DestinationCityViewController alloc] initWithNibName:@"DestinationCityViewController"
                                                                              bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)startDateButtonTapAction:(id)sender
{
    _hasStartDatePicker = !_hasStartDatePicker;
    _hasEndDatePicker = NO;
    [_tableView reloadData];
}

- (IBAction)endDateButtonTapAction:(id)sender
{
    _hasStartDatePicker = NO;
    _hasEndDatePicker = !_hasEndDatePicker;
    [_tableView reloadData];
}

- (IBAction)startDatePickerButtonTapAction:(UIDatePicker *)datePicker
{
    _trip.startDate = datePicker.date;
    [_detailTitles replaceObjectAtIndex:DetailTableRowStartDate
                             withObject:[NSString stringWithFormat:@"Start: %@", [datePicker.date translatedTime]]];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowStartDate inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)endDatePickerButtonTapAction:(UIDatePicker *)datePicker
{
    _trip.endDate = datePicker.date;
    [_detailTitles replaceObjectAtIndex:DetailTableRowEndDate
                             withObject:[NSString stringWithFormat:@"Start: %@", [datePicker.date translatedTime]]];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowEndDate inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)toggleButtonTapAction:(UISwitch *)toggle
{
    _trip.isRoundTrip = [NSNumber numberWithBool:toggle.on];
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return AddTripTableSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case DetailTableRowStartDatePicker:
            return _hasStartDatePicker ? DEFAULT_DATECELL_HEIGHT : 0.0f;
            break;
        case DetailTableRowEndDatePicker:
            return _hasEndDatePicker ? DEFAULT_DATECELL_HEIGHT : 0.0f;
            break;
    }
    
    return DEFAULT_TABLECELL_HEIGHT;
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
                cell.toggle.hidden = YES;
                cell.datePicker.hidden = YES;
                
                cell.textField.placeholder = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.textField.tag = indexPath.row;
                cell.textField.delegate = self;
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if (indexPath.row == DetailTableRowRoundTrip) {
                cell.textField.hidden = YES;
                cell.toggle.hidden = NO;
                cell.datePicker.hidden = YES;
                
                [cell.toggle addTarget:self
                                action:@selector(toggleButtonTapAction:)
                      forControlEvents:UIControlEventValueChanged];
                cell.textLabel.text = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if (indexPath.row == DetailTableRowStartDatePicker) {
                cell.textField.hidden = YES;
                cell.toggle.hidden = YES;
                cell.datePicker.hidden = !_hasStartDatePicker;
                
                [cell.datePicker addTarget:self
                                    action:@selector(startDatePickerButtonTapAction:)
                          forControlEvents:UIControlEventValueChanged];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if (indexPath.row == DetailTableRowEndDatePicker) {
                cell.textField.hidden = YES;
                cell.toggle.hidden = YES;
                cell.datePicker.hidden = !_hasEndDatePicker;
                
                [cell.datePicker addTarget:self
                                    action:@selector(endDatePickerButtonTapAction:)
                          forControlEvents:UIControlEventValueChanged];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.textField.hidden = YES;
                cell.toggle.hidden = YES;
                cell.datePicker.hidden = YES;
                
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
    
    switch (indexPath.section) {
        case AddTripTableSectionDetail:
            switch (indexPath.row) {
                case DetailTableRowDepartureCity:
                    [self departureCityButtonTapAction:nil];
                    break;
                case DetailTableRowDestinationCity:
                    [self destinationCityButtonTapAction:nil];
                    break;
                case DetailTableRowStartDate:
                    [self startDateButtonTapAction:nil];
                    break;
                case DetailTableRowEndDate:
                    [self endDateButtonTapAction:nil];
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableView default data
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
            case DetailTableRowStartDatePicker:
                [mArray insertObject:@"Start Date Picker" atIndex:DetailTableRowStartDatePicker];
                break;
            case DetailTableRowEndDate:
                [mArray insertObject:@"End Date" atIndex:DetailTableRowEndDate];
                break;
            case DetailTableRowEndDatePicker:
                [mArray insertObject:@"End Date Picker" atIndex:DetailTableRowEndDatePicker];
                break;
            case DetailTableRowRoundTrip:
                [mArray insertObject:@"Round Trip" atIndex:DetailTableRowRoundTrip];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    self.navigationItem.rightBarButtonItem.enabled = (newLength > 0);
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification action
- (IBAction)updateDepartureCityNotificationAction:(NSNotification *)notification
{
    if (![notification.object isCityObject]) {
        return;
    }
    City *city = (City *)notification.object;
    
    /* Establish relationship has to be in the same managedObjectContext */
    City *toCityDepartuerCity = [[TripManager sharedInstance] getCityWithCityName:city.cityName context:_managedObjectContext];
    _trip.toCityDepartureCity = toCityDepartuerCity;
    
    [_detailTitles replaceObjectAtIndex:DetailTableRowDepartureCity
                             withObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Departure", nil), city.cityName]];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowDepartureCity inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)updateDestinationCityNotificationAction:(NSNotification *)notification
{
    if (![notification.object isCityObject]) {
        return;
    }
    City *city = (City *)notification.object;
    
    /* Establish relationship has to be in the same managedObjectContext */
    City *toCityDestinationCity = [[TripManager sharedInstance] getCityWithCityName:city.cityName context:_managedObjectContext];
    _trip.toCityDestinationCity = toCityDestinationCity;
    
    [_detailTitles replaceObjectAtIndex:DetailTableRowDestinationCity
                             withObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Destination", nil), city.cityName]];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowDestinationCity inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - NSNotificationCenter
- (void)registerNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDepartureCityNotificationAction:)
                                                 name:TripOperationDidUpdateDepartureCityNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDestinationCityNotificationAction:)
                                                 name:TripOperationDidUpdateDestinationCityNotification
                                               object:nil];
}

- (void)unregisterNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TripOperationDidUpdateDepartureCityNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TripOperationDidUpdateDestinationCityNotification
                                                  object:nil];
}

#pragma mark - UITapGestureRecognizer
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    AddTripTableViewCell *cell = (AddTripTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:DetailTableRowTitle inSection:AddTripTableSectionDetail]];
    [cell.textField resignFirstResponder];
}
@end
