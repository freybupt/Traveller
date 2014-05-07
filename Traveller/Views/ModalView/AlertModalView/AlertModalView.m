//
//  AlertModalView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-07.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AlertModalView.h"

#define ALERT_MODAL_VIEW_TOP 150.0f
#define ALERT_MODAL_VIEW_WIDTH 296.0f
#define ALERT_MODAL_VIEW_HEIGHT 180.0f

@interface AlertModalView ()
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation AlertModalView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    CGRect frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - ALERT_MODAL_VIEW_WIDTH)/2,
                              ALERT_MODAL_VIEW_TOP,
                              ALERT_MODAL_VIEW_WIDTH,
                              ALERT_MODAL_VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        
        if (title) {
            self.titleLabel.text = title;
        } else {
            self.titleLabel.hidden = YES;
        }
        
        if (message) {
            CGFloat y = title ? TITLE_LABEL_HEIGHT : MODAL_VIEW_PADDING * 2;
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(MODAL_VIEW_PADDING * 2,
                                                                      y,
                                                                      ALERT_MODAL_VIEW_WIDTH - MODAL_VIEW_PADDING * 6,
                                                                      ALERT_MODAL_VIEW_HEIGHT - BOTTOM_BUTTON_HEIGHT - MODAL_VIEW_PADDING * 6)];
            _messageLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.text = message;
            _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _messageLabel.numberOfLines = 0;
            [self addSubview:_messageLabel];
        }
        
        
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
