/*
 DSLCalendarDayView.h
 
 Copyright (c) 2012 Dative Studios. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "DSLCalendarDayView.h"
#import "NSDate+DSLCalendarView.h"
//#import "TripManager.h"
#import "CalendarManager.h"

@interface DSLCalendarDayView ()

@property (nonatomic, strong) Trip *activeTrip;
@end


@implementation DSLCalendarDayView {
    __strong NSCalendar *_calendar;
    __strong NSDate *_dayAsDate;
    __strong NSDateComponents *_day;
    __strong NSString *_labelText;
    __strong NSString *_eventDots;
    __strong NSString *_tripLocation;
}


#pragma mark - Initialisation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        _positionInWeek = DSLCalendarDayViewMidWeek;
    }
    
    return self;
}


#pragma mark Properties

- (void)setSelectionState:(DSLCalendarDayViewSelectionState)selectionState {
    _selectionState = selectionState;
    [self setNeedsDisplay];
}

- (void)setDay:(NSDateComponents *)day {
    _calendar = [day calendar];
    _dayAsDate = [day date];
    _day = nil;
    _labelText = [NSString stringWithFormat:@"%ld", (long)day.day];
    
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
}

- (NSDateComponents*)day {
    if (_day == nil) {
        _day = [_dayAsDate dslCalendarView_dayWithCalendar:_calendar];
    }
    
    return _day;
}

- (NSDate*)dayAsDate {
    return _dayAsDate;
}

- (void)setInCurrentMonth:(BOOL)inCurrentMonth {
    _inCurrentMonth = inCurrentMonth;
    [self setNeedsDisplay];
}


#pragma mark UIView methods

- (void)drawRect:(CGRect)rect {
    if ([self isMemberOfClass:[DSLCalendarDayView class]]) {
        //update trip info
        //TripManager *tripManager = [TripManager sharedManager];
        //self.activeTrip = [tripManager findActiveTripByDate:self.day.date];
        [self drawBackground];
        //[self drawBorders];
        [self drawDayNumber];
        [self drawEventsDots];
        [self drawTripLocation];
    }
}


#pragma mark Drawing

- (void)drawBackground {
    UIColor *cellColor = [[CalendarColorManager sharedManager] getSelectionHighlightColor];
    /*
    if (self.activeTrip) {
        cellColor = self.activeTrip.defaultColor;
    }
    */
    const CGFloat * colors = CGColorGetComponents( cellColor.CGColor );
    UIColor *cellColorHighlighted = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:0.8];
    
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        if (self.activeTrip) {
            //already has trip plans
            /*
            if ([self.day.date compare:self.activeTrip.dateRange.startDay.date] == NSOrderedSame ||
                [self.day.date compare:self.activeTrip.dateRange.endDay.date] == NSOrderedSame) {
                [cellColorHighlighted setFill];
            }
            else{
                [cellColor setFill];
            }
            */
            [cellColor setFill];
        }
        else{
            if (self.isInCurrentMonth) {
                [[UIColor colorWithWhite:255.0/255.0 alpha:1.0] setFill];
            }
            else {
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
    
    // TODO: probably add one more DSLCalendarDayViewSelectionState for event
    if (self.tag != 0) {
        [[UIColor redColor] setFill];
    }
    
    UIRectFill(self.bounds);
}

- (void)drawBorders {
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

- (void)drawDayNumber {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:components];
    
    if ([self.dayAsDate isEqualToDate:today]) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected && self.activeTrip == nil) {
        [[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }

    
    UIFont *textFont = [UIFont boldSystemFontOfSize:17.0];
    // TODO: probably add one more DSLCalendarDayViewSelectionState for event
    NSDictionary *attributes = @{ NSFontAttributeName : textFont ,
                                  NSForegroundColorAttributeName : (self.tag != 0) ? [UIColor whiteColor] : [UIColor darkTextColor]};
    CGSize textSize = [_labelText sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [_labelText drawInRect:textRect withAttributes:attributes];
}


- (void)drawEventsDots {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:components];
    
    if ([self.dayAsDate isEqualToDate:today]) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected && self.activeTrip == nil) {
        [[UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }
    
    UIFont *textFont = [UIFont fontWithName:@"Avenir-Light" size:17.0];
    // TODO: probably add one more DSLCalendarDayViewSelectionState for event
    NSDictionary *attributes = @{ NSFontAttributeName : textFont ,
                                  NSForegroundColorAttributeName : (self.tag != 0) ? [UIColor whiteColor] : [UIColor darkTextColor]};
    CGSize textSize = [_eventDots sizeWithFont:textFont];
    
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds)), textSize.width, textSize.height);
    [_eventDots drawInRect:textRect withAttributes:attributes];
}

- (void)drawTripLocation {
    /*
    NSString *tripLocation = self.activeTrip.destinationCity.cityShortName;
    
    BOOL shouldDrawLocation = self.selectionState == DSLCalendarDayViewStartOfSelection ||
                              self.selectionState == DSLCalendarDayViewEndOfSelection ||
                              self.selectionState == DSLCalendarDayViewWholeSelection ||
                              (self.selectionState == DSLCalendarDayViewNotSelected && self.activeTrip &&
                               ([self.day.date compare:self.activeTrip.dateRange.startDay.date] == NSOrderedSame ||
                                [self.day.date compare:self.activeTrip.dateRange.endDay.date] == NSOrderedSame));

    if ([tripLocation length] > 0 && shouldDrawLocation) {
//        NSLog(@"Current date: %@ - %@", self.day.date, tripLocation);
        _tripLocation = [[tripLocation uppercaseString] substringToIndex:2];
    }
    else{
        _tripLocation  = @"";
    }
    */
    
    [[UIColor colorWithRed:131.0/255.0 green:199.0/255.0 blue:149.0/255.0 alpha:1.0] setFill];

    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:components];
    
    if ([self.dayAsDate isEqualToDate:today]) {
        [[UIColor orangeColor] set];
    }
    else if (self.selectionState == DSLCalendarDayViewNotSelected) {
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

