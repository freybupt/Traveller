//
//  ModalView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-20.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ModalView.h"

@implementation ModalView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = frame;
        
        _titleLabel = [self newTitleLabel];
        [self addSubview:_titleLabel];
        
        _leftButton = [self newLeftButton];
        [self addSubview:_leftButton];
        
        _rightButton = [self newRightButton];
        [self addSubview:_rightButton];
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

- (UILabel *)newTitleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TITLE_LABEL_HEIGHT)];
    label.backgroundColor = UIColorFromRGB(0x0C4150);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"TITLE", nil);
    label.font = [UIFont fontWithName:@"Avenir-Heavy" size:16.0f];
    return label;
}

- (UIButton *)newLeftButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(MODAL_VIEW_PADDING * 2,
                                                                  self.frame.size.height - BOTTOM_BUTTON_HEIGHT - MODAL_VIEW_PADDING * 2,
                                                                  BOTTOM_LEFT_BUTTON_WIDTH,
                                                                  BOTTOM_BUTTON_HEIGHT)];
    [button setBackgroundColor:UIColorFromRGB(0xE6E5E6) forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"Left Button", nil) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xB2B2B3) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [button addTarget:self action:@selector(leftButtonTapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [button.layer setCornerRadius:3.0f];
    [button.layer setMasksToBounds:YES];
    
    return button;
}

- (UIButton *)newRightButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - BOTTOM_RIGHT_BUTTON_WIDTH - MODAL_VIEW_PADDING*2,
                                                                  self.frame.size.height - BOTTOM_BUTTON_HEIGHT - MODAL_VIEW_PADDING * 2,
                                                                  BOTTOM_RIGHT_BUTTON_WIDTH,
                                                                  BOTTOM_BUTTON_HEIGHT)];
    [button setBackgroundColor:UIColorFromRGB(0x468966) forState:UIControlStateNormal];
    [button setBackgroundColor:UIColorFromRGB(0xEDEDEF) forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"Right Button", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xD3D5D8) forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]];
    [button addTarget:self action:@selector(rightButtonTapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [button.layer setCornerRadius:3.0f];
    [button.layer setMasksToBounds:YES];
    
    return button;
}

#pragma mark - Show/Dismiss modal view

- (void)show
{
    if ([_delegate respondsToSelector:@selector(willPresentModalView:)]) {
        [_delegate willPresentModalView:self];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [button setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
    [button addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:self];
    [[[UIApplication sharedApplication].delegate window] addSubview:button];
    
    if ([_delegate respondsToSelector:@selector(didPresentModalView:)]) {
        [_delegate didPresentModalView:self];
    }
}

- (IBAction)dismiss:(id)sender
{
    if ([_delegate respondsToSelector:@selector(modalView:willDismissWithButtonIndex:)]) {
        [_delegate modalView:self willDismissWithButtonIndex:ModalViewButtonCancelIndex];
    }
    
    [self removeFromSuperview];
    
    UIButton *button = (UIButton *)sender;
    [button removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(modalView:didDismissWithButtonIndex:)]) {
        [_delegate modalView:self didDismissWithButtonIndex:ModalViewButtonCancelIndex];
    }
}

#pragma mark - Button tap action

- (IBAction)leftButtonTapAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(modalView:clickedButtonAtIndex:)]) {
        [_delegate modalView:self clickedButtonAtIndex:ModalViewButtonCancelIndex];
    }
    
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        [self dismiss:button];
    }
}

- (IBAction)rightButtonTapAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(modalView:clickedButtonAtIndex:)]) {
        [_delegate modalView:self clickedButtonAtIndex:ModalViewButtonFirstOtherIndex];
    }
    
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        [self dismiss:button];
    }
}
@end
