//
//  PLPlanTripCalendarDayView.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-16.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripCalendarDayView.h"

@interface PLPlanTripCalendarDayView ()

@end

@implementation PLPlanTripCalendarDayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark UIView methods

- (void)drawRect:(CGRect)rect
{
    [self drawBackground];
    [self drawBorders];
    [self drawDayNumber];
}

#pragma mark Drawing

- (void)drawBackground
{
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        if (self.isInCurrentMonth) {
            [[UIColor colorWithWhite:245.0/255.0 alpha:1.0] setFill];
        }
        else {
            [[UIColor colorWithWhite:225.0/255.0 alpha:1.0] setFill];
        }
        
        if (self.tag != 0) {
            [[UIColor redColor] setFill];
        }
        
        UIRectFill(self.bounds);
    } else {
        UIColor *cellColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.8f];
        UIColor *cellColorHighlighted = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.6f];
        switch (self.selectionState) {
            case DSLCalendarDayViewWithinSelection:
                [cellColor setFill];
                break;
            case DSLCalendarDayViewStartOfSelection:
            case DSLCalendarDayViewEndOfSelection:
            case DSLCalendarDayViewWholeSelection:
                [cellColorHighlighted setFill];
                break;
            default:
                break;
        }
        
        if (self.tag != 0) {
            [[UIColor redColor] setFill];
        }
        
        UIRectFill(self.bounds);
    }
}

- (void)drawBorders
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:255.0/255.0 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.5, 0.5);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    if (self.isInCurrentMonth) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:205.0/255.0 alpha:1.0].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:185.0/255.0 alpha:1.0].CGColor);
    }
    CGContextMoveToPoint(context, self.bounds.size.width - 0.5, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.0, self.bounds.size.height - 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawDayNumber
{
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        [[UIColor colorWithWhite:66.0/255.0 alpha:1.0] set];
    } else {
        [[UIColor whiteColor] set];
    }
    
    UIFont *textFont = [UIFont boldSystemFontOfSize:17.0];
    NSDictionary *attributes = @{ NSFontAttributeName : textFont ,
                                  NSForegroundColorAttributeName : (self.tag != 0) ? [UIColor whiteColor] : [UIColor darkTextColor]};
    CGSize textSize = [self.labelText sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [self.labelText drawInRect:textRect withAttributes:attributes];
}
@end
