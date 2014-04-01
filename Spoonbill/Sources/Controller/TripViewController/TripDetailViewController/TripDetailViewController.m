//
//  TripDetailViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "TripDetailViewController.h"
#import "AddTripTableViewCell.h"

@interface TripDetailViewController ()

@end

@implementation TripDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                 trip:(Trip *)trip
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.trip = (Trip *)[self.managedObjectContext objectWithID:trip.objectID];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add Trip", nil);
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(doneButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        /* Properties initializing */
        self.managedObjectContext = [self newManagedObjectContext];
        
        /* Boolean initializing */
        self.hasStartDatePicker = NO;
        self.hasEndDatePicker = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)doneButtonTapAction:(id)sender
{
    if ([[TripManager sharedInstance] saveTrip:self.trip context:self.managedObjectContext]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)configureCell:(AddTripTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.textField.hidden = YES;
    cell.toggle.hidden = YES;
    cell.datePicker.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.section) {
        case AddTripTableSectionDetail:{
            switch (indexPath.row) {
                case DetailTableRowTitle:{
                    cell.textField.hidden = NO;
                    cell.textField.text = self.trip.title;
                    cell.textField.placeholder = NSLocalizedString(TRIP_TITLE_TEXTFIELD_PLACEHOLDER, nil);
                    cell.textField.tag = indexPath.row;
                    cell.textField.delegate = self;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }break;
                case DetailTableRowDepartureCity:{
                    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Departure", nil), self.trip.toCityDepartureCity.cityName];
                }break;
                case DetailTableRowDestinationCity:{
                    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Destination", nil), self.trip.toCityDestinationCity.cityName];
                }break;
                case DetailTableRowRoundTrip:{
                    cell.toggle.hidden = NO;
                    cell.toggle.on = [self.trip.isRoundTrip boolValue];
                    [cell.toggle addTarget:self
                                    action:@selector(toggleButtonTapAction:)
                          forControlEvents:UIControlEventValueChanged];
                    cell.textLabel.text = NSLocalizedString(@"Round Trip", nil);
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }break;
                case DetailTableRowStartDate:{
                    cell.textLabel.text = [NSString stringWithFormat:@"Start: %@", [self.trip.startDate translatedTime]];
                }break;
                case DetailTableRowStartDatePicker:{
                    cell.datePicker.hidden = !self.hasStartDatePicker;
                    [cell.datePicker addTarget:self
                                        action:@selector(startDatePickerButtonTapAction:)
                              forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }break;
                case DetailTableRowEndDate:{
                    cell.textLabel.text = [NSString stringWithFormat:@"End: %@", [self.trip.endDate translatedTime]];
                }break;
                case DetailTableRowEndDatePicker:{
                    cell.datePicker.hidden = !self.hasEndDatePicker;
                    [cell.datePicker addTarget:self
                                        action:@selector(endDatePickerButtonTapAction:)
                              forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }break;
                case DetailTableRowDefaultColor:{
                    UIColor *backgroundColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:self.trip.defaultColor];
                    cell.backgroundColor = backgroundColor;
                    cell.textLabel.text = NSLocalizedString(@"Default Color", nil);
                }break;
            }
        }break;
        case AddTripTableSectionEvent:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", NSLocalizedString(@"Events", nil), [NSNumber numberWithInteger:[self.trip.toEvent count]]];
            break;
    }
}
@end
