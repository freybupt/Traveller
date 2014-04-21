//
//  DestinationTableViewCell.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DestinationTableViewCell.h"

@interface DestinationTableViewCell ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *indicatorView;
@end

@implementation DestinationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _textField = [self newTextField];
    [self addSubview:_textField];
    
    _indicatorView = [self newIndicatorView];
    [self addSubview:_indicatorView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Configuration
- (BDTextField *)newTextField
{
    BDTextField *field = [[BDTextField alloc] initWithFrame:CGRectMake(32.0f,
                                                                       (self.frame.size.height - 30.0f)/2,
                                                                       250.f,
                                                                       30.0f)];
    field.textField.placeholder = NSLocalizedString(@"Enter a destination", nil);
    field.textField.delegate = self;
    
    return field;
}

- (UIView *)newIndicatorView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14.0f,
                                                            (self.frame.size.height - 5.0f)/2,
                                                            5.0f,
                                                            5.0f)];
    view.backgroundColor = UIColorFromRGB(0xD3D5D8);
    [view.layer setCornerRadius:view.frame.size.width/2];
    
    return view;
}

#pragma mark - Configuration
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = UIColorFromRGB(0x458A67);
    
    _indicatorView.backgroundColor = UIColorFromRGB(0x458A67);
    
    [_textField.layer setBorderWidth:2.0f];
    [_textField.layer setBorderColor:UIColorFromRGB(0x458A67).CGColor];
    [_textField.layer setCornerRadius:3.0f];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.textColor = UIColorFromRGB(0xD3D5D8);
    
    _indicatorView.backgroundColor = UIColorFromRGB(0xD3D5D8);
    
    [_textField.layer setBorderWidth:1.0f];
    [_textField.layer setBorderColor:UIColorFromRGB(0xD3D5D8).CGColor];
    [_textField.layer setCornerRadius:3.0f];
}
@end
