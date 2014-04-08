//
//  PLPlanTripCalendarHeaderFooterView.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-08.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripCalendarHeaderFooterView.h"

#define PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH 30.0f
#define PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_HEIGHT 30.0f

@implementation PLPlanTripCalendarHeaderFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _middleButton = [self newMiddleButton];
        [self.contentView addSubview:_middleButton];
        
        _rightButton = [self newRightButton];
        [self.contentView addSubview:_rightButton];
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
- (UIButton *)newMiddleButton;
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH)/2,
                                                                  (PLANTRIPCALENDAR_HEADERFOOTER_HEIGHT- PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH)/2,
                                                                  PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH,
                                                                  PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_HEIGHT)];
    [button setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateSelected];
    
    return button;
}

- (UIButton *)newRightButton;
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH,
                                                                  (PLANTRIPCALENDAR_HEADERFOOTER_HEIGHT- PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH)/2,
                                                                  PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_WIDTH,
                                                                  PLANTRIPCALENDAR_HEADERFOOTER_BUTTON_HEIGHT)];
    [button setImage:[UIImage imageNamed:@"add-item"] forState:UIControlStateNormal];
    
    return button;
}
@end
