//
//  DestinationModalView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-20.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DestinationModalView.h"

#define DESTINATION_MODAL_VIEW_TOP 77.0f
#define DESTINATION_MODAL_VIEW_WIDTH 296.0f
#define DESTINATION_MODAL_VIEW_HEIGHT 220.0f

@implementation DestinationModalView

- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    CGRect frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - DESTINATION_MODAL_VIEW_WIDTH)/2,
                              DESTINATION_MODAL_VIEW_TOP,
                              DESTINATION_MODAL_VIEW_WIDTH,
                              DESTINATION_MODAL_VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = title;
        self.delegate = delegate;
        [self.leftButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.rightButton setTitle:otherButtonTitle forState:UIControlStateNormal];
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

@end
