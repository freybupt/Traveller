//
//  DestinationTableViewCell.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDTextField.h"

#define DESTINATION_TABLEVIEW_CELL_HEIGHT 40.0f

@interface DestinationTableViewCell : UITableViewCell
@property (nonatomic, strong) BDTextField *textField;
@end
