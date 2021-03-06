//
//  CalendarDayView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-18.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarDayView.h"

@interface CalendarDayView ()

@end

@implementation CalendarDayView
{
    __strong NSString *_eventDots;
    __strong NSString *_tripLocation;
    __strong UIColor *_defaultColor;
}

- (void)setDay:(NSDateComponents *)day
{
    self.tag = [day uniqueDateNumber];
    _calendar = [day calendar];
    _dayAsDate = [day date];
    _day = nil;
    _labelText = [NSString stringWithFormat:@"%ld", (long)day.day];
    /*
    CalendarManager *calendarManager = [CalendarManager sharedManager];
    //find event number for this day
    NSDate *startDate = day.date;
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 1;
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    // We will only search the default calendar for our events
    if (calendarManager.eventStore.defaultCalendarForNewEvents) {
        NSArray *calendarArray = [NSArray arrayWithObject:calendarManager.eventStore.defaultCalendarForNewEvents];
        
        // Create the predicate
        NSPredicate *predicate = [calendarManager.eventStore predicateForEventsWithStartDate:startDate
                                                                                     endDate:endDate
                                                                                   calendars:calendarArray];
        // Fetch all events that match the predicate
        NSMutableArray *events = [NSMutableArray arrayWithArray:[calendarManager.eventStore eventsMatchingPredicate:predicate]];
        NSInteger eventCount = [events count];
        NSString *eventDotString = @"";
        if (eventCount > 3) {
            eventDotString = @"...";
        }
        else if (eventCount > 1){
            eventDotString = @"..";
        }
        else if (eventCount > 0)
        {
            eventDotString = @".";
        }
        _eventDots = eventDotString;
    }
    */
}

- (void)drawRect:(CGRect)rect
{
    if ([self isMemberOfClass:[CalendarDayView class]]) {
        _defaultColor = (UIColor *)[[[TripManager sharedManager] tripColorDictionary] objectForKey:[NSNumber numberWithInteger:[self.day uniqueDateNumber]]];
        [self drawBackground];
        [self drawDayNumber];
        //[self drawEventsDots];
        [self drawTripLocation];
        
    }
}

#pragma mark Drawing
- (void)drawBackground
{
    UIColor *cellColor = [[CalendarColorManager sharedManager] getSelectionHighlightColor];
    if (_defaultColor) {
        cellColor = _defaultColor;
    }
    
    const CGFloat * colors = CGColorGetComponents( cellColor.CGColor );
    UIColor *cellColorHighlighted = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:0.8];
    
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        if (_defaultColor) {
            [cellColor setFill];
        } else {
            if (self.isInCurrentMonth) {
                [[UIColor colorWithWhite:255.0/255.0 alpha:1.0] setFill];
            } else {
                [[UIColor colorWithWhite:225.0/255.0 alpha:1.0] setFill];
            }
        }
    }
    else {
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
    }
    
    UIRectFill(self.bounds);
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
    UIFont *textFont = [UIFont boldSystemFontOfSize:17.0];
    NSDictionary *attributes = @{ NSFontAttributeName : textFont ,
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]};

    if (_defaultColor) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected &&
             _defaultColor == nil) {
        [[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }
    
    CGSize textSize = [_labelText sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [_labelText drawInRect:textRect withAttributes:attributes];
}


- (void)drawEventsDots
{
    NSDate *today = [NSDate date];
    
    UIFont *textFont = [UIFont fontWithName:@"Avenir-Light" size:17.0];
    NSDictionary *attributes = @{ NSFontAttributeName : textFont ,
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]};
    
    if ([self.dayAsDate isEqualToDate:today]) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected &&
             _defaultColor == nil) {
        [[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }
    
    CGSize textSize = [_eventDots sizeWithFont:textFont];
    
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds)), textSize.width, textSize.height);
    [_eventDots drawInRect:textRect withAttributes:attributes];
}

- (void)drawTripLocation
{
    NSString *tripLocation = [[[TripManager sharedManager] tripCityCodeDictionary] objectForKey:[NSNumber numberWithInteger:[self.day uniqueDateNumber]]];
    _tripLocation = ([tripLocation length] > 1) ? [[tripLocation uppercaseString] substringToIndex:2] : [tripLocation uppercaseString];
    
    [[UIColor colorWithRed:131.0/255.0 green:199.0/255.0 blue:149.0/255.0 alpha:1.0] setFill];
    
    NSDate *today = [NSDate date];
    
    if ([self.dayAsDate isEqualToDate:today]) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected && tripLocation == nil) {
        [[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }
    
    UIFont *textFont = [UIFont fontWithName:@"Avenir-Light" size:10.0];
    CGSize textSize = [_tripLocation sizeWithFont:textFont];
    
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), 1, textSize.width, textSize.height);
    [_tripLocation drawInRect:textRect withFont:textFont];
}

@end


