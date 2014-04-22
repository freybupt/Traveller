//
//  PLAutocompleteViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-22.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLAutocompleteViewController.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

@interface PLAutocompleteViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet HTAutocompleteTextField *textField;
@end

@implementation PLAutocompleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Autocomplete", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    _textField.autocompleteType = HTAutocompleteTypeCity;
    _textField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)doneButtonTapAction:(id)sender
{
    [_textField resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
@end
