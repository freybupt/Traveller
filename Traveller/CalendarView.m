//
//  CalendarView.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarView.h"
#import "DSLCalendarDayView.h"
#import "DSLCalendarMonthSelectorView.h"
#import "DSLCalendarMonthView.h"
#import "DSLCalendarView.h"
#import "DSLCalendarDayView.h"


@interface DSLCalendarView ()

@property (nonatomic, copy) NSDateComponents *draggingFixedDay;
@property (nonatomic, copy) NSDateComponents *draggingStartDay;
@property (nonatomic, assign) BOOL draggedOffStartDay;

@property (nonatomic, strong) NSMutableDictionary *monthViews;
@property (nonatomic, strong) UIView *monthContainerView;
@property (nonatomic, strong) UIView *monthContainerViewContentView;
@property (nonatomic, strong) DSLCalendarMonthSelectorView *monthSelectorView;

@end

@implementation CalendarView{
    CGFloat _dayViewHeight;
    NSDateComponents *_visibleMonth;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DSLCalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    self.draggingStartDay = touchedView.day;
    self.draggingFixedDay = touchedView.day;
    self.draggedOffStartDay = NO;
    
    DSLCalendarRange *newRange = self.selectedRange;
    if (self.selectedRange == nil) {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    else if (![self.selectedRange.startDay isEqual:touchedView.day] && ![self.selectedRange.endDay isEqual:touchedView.day]) {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    else if ([self.selectedRange.startDay isEqual:touchedView.day]) {
        self.draggingFixedDay = self.selectedRange.endDay;
    }
    else {
        self.draggingFixedDay = self.selectedRange.startDay;
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didDragToDay:selectingRange:)]) {
        newRange = [self.delegate calendarView:self didDragToDay:touchedView.day selectingRange:newRange];
    }
    self.selectedRange = newRange;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.draggingStartDay == nil) {
        return;
    }
    
    DSLCalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    DSLCalendarRange *newRange;
    if ([touchedView.day.date compare:self.draggingFixedDay.date] == NSOrderedAscending) {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:self.draggingFixedDay];
    }
    else {
        newRange = [[DSLCalendarRange alloc] initWithStartDay:self.draggingFixedDay endDay:touchedView.day];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didDragToDay:selectingRange:)]) {
        newRange = [self.delegate calendarView:self didDragToDay:touchedView.day selectingRange:newRange];
    }
    self.selectedRange = newRange;
    
    if (!self.draggedOffStartDay) {
        if (![self.draggingStartDay isEqual:touchedView.day]) {
            self.draggedOffStartDay = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.draggingStartDay == nil) {
        return;
    }
    
    DSLCalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    if (!self.draggedOffStartDay && [self.draggingStartDay isEqual:touchedView.day]) {
        self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    
    self.draggingStartDay = nil;
    
    // Check if the user has dragged to a day in an adjacent month
//    if (touchedView.day.year != _visibleMonth.year || touchedView.day.month != _visibleMonth.month) {
//        // Ask the delegate if it's OK to animate to the adjacent month
//        BOOL animateToAdjacentMonth = YES;
//        if ([self.delegate respondsToSelector:@selector(calendarView:shouldAnimateDragToMonth:)]) {
//            animateToAdjacentMonth = [self.delegate calendarView:self shouldAnimateDragToMonth:[touchedView.dayAsDate dslCalendarView_monthWithCalendar:_visibleMonth.calendar]];
//        }
//        
//        if (animateToAdjacentMonth) {
//            if ([touchedView.dayAsDate compare:_visibleMonth.date] == NSOrderedAscending) {
//                [self didTapMonthBack:nil];
//            }
//            else {
//                [self didTapMonthForward:nil];
//            }
//        }
//    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)]) {
        [self.delegate calendarView:self didSelectRange:self.selectedRange];
    }
    
}


- (DSLCalendarDayView*)dayViewForTouches:(NSSet*)touches {
    if (touches.count != 1) {
        return nil;
    }
    
    UITouch *touch = [touches anyObject];
    
    // Check if the touch is within the month container
    if (!CGRectContainsPoint(self.monthContainerView.frame, [touch locationInView:self.monthContainerView.superview])) {
        return nil;
    }
    
    // Work out which day view was touched. We can't just use hit test on a root view because the month views can overlap
    for (DSLCalendarMonthView *monthView in self.monthViews.allValues) {
        UIView *view = [monthView hitTest:[touch locationInView:monthView] withEvent:nil];
        if (view == nil) {
            continue;
        }
        
        while (view != monthView) {
            if ([view isKindOfClass:[DSLCalendarDayView class]]) {
                return (DSLCalendarDayView*)view;
            }
            
            view = view.superview;
        }
    }
    
    return nil;
}
@end
