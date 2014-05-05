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
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, weak) IBOutlet HTAutocompleteTextField *eventLocationTextField;
@property (nonatomic, weak) IBOutlet UIImageView *locationImageView;
@property (nonatomic, weak) IBOutlet Checkbox *checkBox;
@property (nonatomic, weak) IBOutlet UIView *locationView;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventTypeImageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;

@end
