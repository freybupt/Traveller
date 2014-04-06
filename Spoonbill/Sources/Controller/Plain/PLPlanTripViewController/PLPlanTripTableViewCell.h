//
//  PLPlanTripTableViewCell.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Checkbox.h"

#define PLANTRIP_TABLEVIEWCELL_HEIGHT 55.0f
#define PLANTRIP_TABLEVIEWCELL_PADDING 5.0f

@interface PLPlanTripTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) Checkbox *checkBox;
@end
