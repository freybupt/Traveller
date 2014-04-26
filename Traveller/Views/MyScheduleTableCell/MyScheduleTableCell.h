//
//  MyScheduleTableCell.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Checkbox.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

@interface MyScheduleTableCell : UITableViewCell

@property (nonatomic, weak) Event *event;
@property (nonatomic, strong) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, strong) IBOutlet HTAutocompleteTextField *eventLocationTextField;
@property (nonatomic, strong) IBOutlet UIImageView *locationImageView;
@property (nonatomic, strong) IBOutlet Checkbox *checkBox;
@property (nonatomic, strong) IBOutlet UIView *locationView;

@end
