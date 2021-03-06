//
//  DepartureTableViewCell.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDTextField.h"

#define DEPARTURE_TABLEVIEW_CELL_HEIGHT 30.0f

@interface DepartureTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) BDTextField *textField;
@end
