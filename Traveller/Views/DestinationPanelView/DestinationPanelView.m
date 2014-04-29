//
//  DestinationPanelView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-28.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DestinationPanelView.h"
#import "HTAutocompleteManager.h"

@interface DestinationPanelView ()<UITextFieldDelegate>

@end

@implementation DestinationPanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    
    _destinationTextField = [self newDestinationTextField];
    [self addSubview:_destinationTextField];
    
    _departureLocationTextField = [self newDepartureLocationTextField];
    [self addSubview:_departureLocationTextField];
    
    _removeTripButton = [self newRemoveTripButton];
    [self addSubview:_removeTripButton];
    
    _confirmDestinationButton = [self newConfirmDestinationButton];
    [self addSubview:_confirmDestinationButton];
    
    _cancelEditDestinationButton = [self newCancelEditDestinationButton];
    [self addSubview:_cancelEditDestinationButton];
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
- (HTAutocompleteTextField *)newDestinationTextField
{
    HTAutocompleteTextField *textField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 200.0f, 40.0f)];
    textField.placeholder = NSLocalizedString(@"Add Destination", nil);
    textField.font = [UIFont fontWithName:@"Avenir-Roman" size:17.0f];
    textField.minimumFontSize = 17.0f;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.borderStyle = UITextBorderStyleNone;
    textField.hidden = NO;
    textField.delegate = self;
    textField.autocompleteType = HTAutocompleteTypeCity;
    
    return textField;
}

- (UITextField *)newDepartureLocationTextField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 200.0f, 40.0f)];
    textField.placeholder = NSLocalizedString(@"Departure Location", nil);
    textField.font = [UIFont fontWithName:@"Avenir-Roman" size:17.0f];
    textField.minimumFontSize = 17.0f;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.borderStyle = UITextBorderStyleNone;
    textField.hidden = YES;
    textField.delegate = self;
    
    return textField;
}

- (UIButton *)newRemoveTripButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(179.0f, 3.0f, 32.0f, 32.0f)];
    [button setImage:[UIImage imageNamed:@"dustbin"] forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *)newConfirmDestinationButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(270.0f, 5.0f, 50.0f, 28.0f)];
    [button setTitle:NSLocalizedString(@"✓", nil) forState:UIControlStateNormal];
    button.backgroundColor = UIColorFromRGB(0x93CFA6);
    button.enabled = NO;
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];

    return button;
}

- (UIButton *)newCancelEditDestinationButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(219.0f, 5.0f, 50.0f, 28.0f)];
    [button setTitle:NSLocalizedString(@"X", nil) forState:UIControlStateNormal];
    button.backgroundColor = UIColorFromRGB(0xC0C0C0);
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    
    return button;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    _confirmDestinationButton.enabled = (newLength > 0);
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = [textField.text uppercaseStringToIndex:1];
    [textField resignFirstResponder];
    
    return NO;
}
@end
