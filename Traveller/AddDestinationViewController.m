//
//  AddDestinationViewController.m
//  Traveller
//
//  Created by Shirley on 2/19/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddDestinationViewController.h"

@interface AddDestinationViewController ()

@end

@implementation AddDestinationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)didTapCancelButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPopupNotification object:self userInfo:nil];

}


- (IBAction)didTapConfirmButton:(id)sender
{
    NSDictionary *destinationDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.destinationTextField.text, @"destinationString", self.departureLocationTextField.text, @"departureStrong", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPopupNotification object:self userInfo:destinationDict];
}
@end
