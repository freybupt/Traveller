//
//  AddTripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddTripViewController.h"
#import "AddTripTableViewCell.h"
#import "ChooseEventViewController.h"
#import "DepartureCityViewController.h"
#import "DestinationCityViewController.h"
#import "FCColorPickerViewController.h"

#define ADDTRIP_TABLEVIEWCELL_IDENTIFIER @"AddTripTableViewCellIdentifier"
#define MINIMUM_TEXTFIELD_LENGTH_FOR_SAVING 0
#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithRed:0.561f green:0.952f blue:1.0f alpha:1.0f]
#define HOUR_INTERVAL 60 * 60
@interface AddTripViewController ()<FCColorPickerViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *detailTitles;
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
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(doneButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        /* Properties initializing */
        _managedObjectContext = [self newManagedObjectContext];
        _trip = [self newTrip];
        _detailTitles = [[NSMutableArray alloc] initWithArray:[self defaultDetailTitles]];
        
        /* Boolean initializing */
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self defaultCityButtonTapAction:nil];
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
    if (![[TripManager sharedInstance] deleteTrip:_trip context:_managedObjectContext]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when removing a trip item in Core Data", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)doneButtonTapAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)chooseEventButtonTapAction:(id)sender
{
    ChooseEventViewController *vc = [[ChooseEventViewController alloc] initWithNibName:@"ChooseEventViewController"
                                                                                bundle:nil
                                                                                  trip:_trip];
    [self.navigationController pushViewController:vc animated:YES];
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

- (IBAction)colorPickerButtonTapAction:(id)sender
{
    FCColorPickerViewController *vc = [FCColorPickerViewController colorPicker];
    vc.color = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:_trip.defaultColor];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.backgroundColor = [UIColor blackColor];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)defaultCityButtonTapAction:(id)sender
{
    if (_trip.toCityDepartureCity &&
        _trip.toCityDestinationCity) {
        return;
    }
    
    City *city = [[TripManager sharedInstance] getCityWithCityName:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_KEY] context:_managedObjectContext];
    if (city) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TripOperationDidUpdateDepartureCityNotification
                                                                object:city
                                                              userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TripOperationDidUpdateDestinationCityNotification
                                                                object:city
                                                              userInfo:nil];
        });
    }
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
    cell.backgroundColor = [UIColor whiteColor];
    cell.textField.hidden = YES;
    cell.toggle.hidden = YES;
    cell.datePicker.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case AddTripTableSectionDetail:{
            if (indexPath.row == DetailTableRowTitle) {
                cell.textField.hidden = NO;
                cell.textField.placeholder = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.textField.tag = indexPath.row;
                cell.textField.delegate = self;
            } else if (indexPath.row == DetailTableRowRoundTrip) {
                cell.toggle.hidden = NO;
                [cell.toggle addTarget:self
                                action:@selector(toggleButtonTapAction:)
                      forControlEvents:UIControlEventValueChanged];
                cell.textLabel.text = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
            } else if (indexPath.row == DetailTableRowStartDatePicker) {
                cell.datePicker.hidden = !_hasStartDatePicker;
                [cell.datePicker addTarget:self
                                    action:@selector(startDatePickerButtonTapAction:)
                          forControlEvents:UIControlEventValueChanged];
            } else if (indexPath.row == DetailTableRowEndDatePicker) {
                cell.datePicker.hidden = !_hasEndDatePicker;
                [cell.datePicker addTarget:self
                                    action:@selector(endDatePickerButtonTapAction:)
                          forControlEvents:UIControlEventValueChanged];
            } else {
                if (indexPath.row == DetailTableRowDefaultColor) {
                    UIColor *backgroundColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:_trip.defaultColor];
                    cell.backgroundColor = backgroundColor;
                }
                cell.textLabel.text = NSLocalizedString([_detailTitles objectAtIndex:indexPath.row], nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }break;
        case AddTripTableSectionEvent:
            cell.textField.hidden = YES;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", NSLocalizedString(@"Events", nil), [NSNumber numberWithInteger:[_trip.toEvent count]]];
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
                case DetailTableRowDefaultColor:
                    [self colorPickerButtonTapAction:nil];
                    break;
            }
            break;
        case AddTripTableSectionEvent:
            switch (indexPath.row) {
                case EventTableRowAdd:
                    [self chooseEventButtonTapAction:nil];
                    break;
            }
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] > MINIMUM_TEXTFIELD_LENGTH_FOR_SAVING) {
        _trip.title = textField.text;
        [[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext];
    }
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
    if ([[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext]) {
        self.navigationItem.rightBarButtonItem.enabled = [self didInsertDepartureAndDestinationCity];
    }
    
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
    if ([[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext]) {
        self.navigationItem.rightBarButtonItem.enabled = [self didInsertDepartureAndDestinationCity];
    }
    
    [_detailTitles replaceObjectAtIndex:DetailTableRowDestinationCity
                             withObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Destination", nil), city.cityName]];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowDestinationCity inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)updateTripEventsNotificationAction:(NSNotification *)notification
{
    if (![notification.object isEventObject]) {
        return;
    }

    Event *event = (Event *)[_managedObjectContext objectWithID:[notification.object objectID]];
    if ([_trip.toEvent containsObject:event]) {
        [_trip removeToEventObject:event];
    } else {
        [_trip addToEventObject:event];
    }
    
    if ([[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext]) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:AddTripTableSectionEvent]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTripEventsNotificationAction:)
                                                 name:TripOperationDidUpdateTripEventsNotification
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TripOperationDidUpdateTripEventsNotification
                                                  object:nil];
}

#pragma mark - UITapGestureRecognizer
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    AddTripTableViewCell *cell = (AddTripTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:DetailTableRowTitle inSection:AddTripTableSectionDetail]];
    [cell.textField resignFirstResponder];
}

#pragma mark - Configuration
- (NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext new];
    managedObjectContext.undoManager = nil;
    managedObjectContext.persistentStoreCoordinator = [[TripManager sharedInstance] persistentStoreCoordinator];
    
    return managedObjectContext;
}

- (Trip *)newTrip
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip"
                                              inManagedObjectContext:_managedObjectContext];
    Trip *trip = [[Trip alloc] initWithEntity:entity
               insertIntoManagedObjectContext:_managedObjectContext];
    trip.title = NSLocalizedString(@"New Trip", nil);
    trip.startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    trip.endDate = [NSDate dateWithTimeIntervalSinceNow:HOUR_INTERVAL];
    trip.defaultColor = [NSKeyedArchiver archivedDataWithRootObject:DEFAULT_BACKGROUND_COLOR];
    trip.uid = [MockManager userid];
    
    return trip;
}

#pragma mark - Helper
- (BOOL)didInsertDepartureAndDestinationCity
{
    return (_trip.toCityDepartureCity && _trip.toCityDestinationCity);
}

#pragma mark - FCColorPickerViewControllerDelegate Methods
-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color
{
    _trip.defaultColor = [NSKeyedArchiver archivedDataWithRootObject:color];
    if ([[TripManager sharedInstance] saveTrip:_trip context:_managedObjectContext]) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DetailTableRowDefaultColor inSection:AddTripTableSectionDetail]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    AddTripTableViewCell *cell = (AddTripTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:DetailTableRowTitle inSection:AddTripTableSectionDetail]];
    if (cell.textField.editing) {
        [cell.textField resignFirstResponder];
    }
    
    if (_hasStartDatePicker) {
        [self startDateButtonTapAction:nil];
    }
    
    if (_hasEndDatePicker) {
        [self endDateButtonTapAction:nil];
    }
}
@end
