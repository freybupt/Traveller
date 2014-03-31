//
//  AddTripTableViewCell.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddCityTableViewCell.h"

#define DEFAULT_TABLECELL_HEIGHT 45.0f
#define DEFAULT_DATECELL_HEIGHT 200.0f

@interface AddTripTableViewCell : AddCityTableViewCell
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end
