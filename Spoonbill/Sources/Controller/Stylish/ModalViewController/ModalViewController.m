//
//  ModalViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-22.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ModalViewController.h"
#import "DestinationModalView.h"

@interface ModalViewController ()<ModalViewDelegate>

@end

@implementation ModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Modal View", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DestinationModalView *modalView = [[DestinationModalView alloc] initWithTitle:NSLocalizedString(@"I'M GOING TO BE IN...", nil)
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"Go Back", nil)
                                                                 otherButtonTitle:NSLocalizedString(@"Confirm", nil)];
    [modalView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ModalView delegate
- (void)modalView:(ModalView *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case ModalViewButtonCancelIndex:
            NSLog(@"Cancel");
            break;
        case ModalViewButtonFirstOtherIndex:
            NSLog(@"Confirm");
            break;
    }
}
@end
