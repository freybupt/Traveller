//
//  UIButton+Extensions.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIButton+Extensions.h"

@implementation UIButton (Extensions)
- (void)setBackgroundColor:(UIColor *)color
                  forState:(UIControlState)state
{
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = color;
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:image forState:state];
}
@end
