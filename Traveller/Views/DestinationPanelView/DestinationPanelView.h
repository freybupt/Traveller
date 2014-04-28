//
//  DestinationPanelView.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-28.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinationPanelView : UIView
@property (nonatomic, strong) UITextField *destinationTextField;
@property (nonatomic, strong) UITextField *departureLocationTextField;
@property (nonatomic, strong) UIButton *removeTripButton;
@property (nonatomic, strong) UIButton *confirmDestinationButton;
@property (nonatomic, strong) UIButton *cancelEditDestinationButton;
@end
