//
//  AddDestinationViewController.h
//  Traveller
//
//  Created by Shirley on 2/19/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString *const kDismissPopupNotification = @"dismissDestinationPopup";

@interface AddDestinationViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *confirmButton;

@property (nonatomic, weak) IBOutlet UILabel *timelabel;
@property (nonatomic, weak) IBOutlet UITextField *destinationTextField;
@property (nonatomic, weak) IBOutlet UITextField *departureLocationTextField;


- (IBAction)didTapCancelButton:(id)sender;
- (IBAction)didTapConfirmButton:(id)sender;
@end
