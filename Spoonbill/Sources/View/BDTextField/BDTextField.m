//
//  BDTextField.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "BDTextField.h"

#define TEXTFIELD_PADDING 10.0f

@interface BDTextField ()<UITextFieldDelegate>

@end

@implementation BDTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:UIColorFromRGB(0xD3D5D8).CGColor];
        [self.layer setCornerRadius:3.0f];
        
        _textField = [self newTextField];
        [self addSubview:_textField];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Configuration
- (UITextField *)newTextField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXTFIELD_PADDING,
                                                                           TEXTFIELD_PADDING/2,
                                                                           self.frame.size.width - TEXTFIELD_PADDING * 2,
                                                                           self.frame.size.height - TEXTFIELD_PADDING)];
    textField.textColor = UIColorFromRGB(0x458A67);
    textField.font = [UIFont boldSystemFontOfSize:16];
    textField.placeholder = NSLocalizedString(@"Enter text here...", nil);
    textField.delegate = self;
    
    return textField;
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = UIColorFromRGB(0x458A67);
    
    [self.layer setBorderWidth:2.0f];
    [self.layer setBorderColor:UIColorFromRGB(0x458A67).CGColor];
    [self.layer setCornerRadius:3.0f];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.textColor = UIColorFromRGB(0xD3D5D8);
    
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:UIColorFromRGB(0xD3D5D8).CGColor];
    [self.layer setCornerRadius:3.0f];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
@end
