//
//  AddTripViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "SBViewController.h"

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

@interface AddTripViewController : SBViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Trip *trip;
@property (nonatomic, assign) BOOL hasStartDatePicker;
@property (nonatomic, assign) BOOL hasEndDatePicker;

- (IBAction)startDatePickerButtonTapAction:(UIDatePicker *)datePicker;
- (IBAction)endDatePickerButtonTapAction:(UIDatePicker *)datePicker;
- (IBAction)toggleButtonTapAction:(UISwitch *)toggle;
- (NSManagedObjectContext *)newManagedObjectContext;
@end
