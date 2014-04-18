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
//#import "TripManager.h"

@interface DSLCalendarView ()

@property (nonatomic, copy) NSDateComponents *draggingFixedDay;
@property (nonatomic, copy) NSDateComponents *draggingStartDay;
@property (nonatomic, assign) BOOL draggedOffStartDay;

@property (nonatomic, strong) NSMutableDictionary *monthViews;
@property (nonatomic, strong) UIView *monthContainerView;
@property (nonatomic, strong) UIView *monthContainerViewContentView;
@property (nonatomic, strong) DSLCalendarMonthSelectorView *monthSelectorView;
@end

@implementation CalendarView

#pragma mark - Events

- (void)didTapMonthBack:(id)sender {
    NSDateComponents *newMonth = self.visibleMonth;
    newMonth.month--;
    
    [self setVisibleMonth:newMonth animated:YES];
}

- (void)didTapMonthForward:(id)sender {
    NSDateComponents *newMonth = self.visibleMonth;
    newMonth.month++;
    
    [self setVisibleMonth:newMonth animated:YES];
}

- (void)animateMoveToAdjacentMonth:(NSDateComponents *)day
{
    // Check if the user has dragged to a day in an adjacent month
    if (day.year != self.visibleMonth.year || day.month != self.visibleMonth.month) {
        // Ask the delegate if it's OK to animate to the adjacent month
        BOOL animateToAdjacentMonth = YES;
        if ([self.delegate respondsToSelector:@selector(calendarView:shouldAnimateDragToMonth:)]) {
            animateToAdjacentMonth = [self.delegate calendarView:self shouldAnimateDragToMonth:[day.date dslCalendarView_monthWithCalendar:self.visibleMonth.calendar]];
        }
        
        if (animateToAdjacentMonth) {
            if ([day.date compare:self.visibleMonth.date] == NSOrderedAscending) {
                [self didTapMonthBack:nil];
            }
            else {
                [self didTapMonthForward:nil];
            }
        }
    }
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
    
    self.editingTrip = nil;
    //already have trip
    /*
    Trip *activeTrip = [[TripManager sharedManager] findActiveTripByDate:touchedView.day.date];
    if (activeTrip) {
        [self.delegate calendarView:self shouldHighlightTrip:activeTrip];
        self.originalTrip = [[Trip alloc] initWithExistingTrip:activeTrip];
        self.selectedRange = activeTrip.dateRange;
        if ([touchedView.day.date isEqualToDate:activeTrip.dateRange.startDay.date] ||
            [touchedView.day.date isEqualToDate:activeTrip.dateRange.endDay.date]) {
            self.editingTrip = [[Trip alloc] initWithExistingTrip:activeTrip];
        }
    }
    else{
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
    */
    
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
    
    //TODO: check within current range whether there is trip plan already?
    //modify current trip
    /*
    if (self.editingTrip) {
        DSLCalendarRange *newRange;
        if ([touchedView.day.date compare:self.editingTrip.dateRange.startDay.date] == NSOrderedAscending){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:self.editingTrip.dateRange.endDay];
        }
        else if ([touchedView.day.date compare:self.editingTrip.dateRange.endDay.date] == NSOrderedDescending) {
            newRange = [[DSLCalendarRange alloc] initWithStartDay:self.editingTrip.dateRange.startDay endDay:touchedView.day];
        }
        else if([self.draggingStartDay isEqual:self.editingTrip.dateRange.startDay]){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:self.editingTrip.dateRange.endDay];
        }
        else if([self.draggingStartDay isEqual:self.editingTrip.dateRange.endDay]){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:self.editingTrip.dateRange.startDay endDay:touchedView.day];
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
    else if ([[TripManager sharedManager] findActiveTripByDate:touchedView.day.date]) {
        self.selectedRange = nil;
    }
    else{
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
    */
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
    
    /*
    if (self.editingTrip) {
        Trip *updatedTrip = [[Trip alloc] initWithExistingTrip:self.editingTrip];
        updatedTrip.dateRange = self.selectedRange;
        self.editingTrip = updatedTrip;
        if ([self.delegate respondsToSelector:@selector(calendarView:didModifytrip:toNewTrip:)]) {
            [self.delegate calendarView:self didModifytrip:self.originalTrip toNewTrip:updatedTrip];
        }
    }
    else if([[TripManager sharedManager] findActiveTripByDate:touchedView.day.date]) {
        //don't create new trip on existing one
        return;
    }
    else{
        if (!self.draggedOffStartDay && [self.draggingStartDay isEqual:touchedView.day]) {
            self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
        }
        
        if ([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)]) {
            [self.delegate calendarView:self didSelectRange:self.selectedRange];
        }
    }
    */
    if (!self.draggedOffStartDay && [self.draggingStartDay isEqual:touchedView.day]) {
        self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)]) {
        [self.delegate calendarView:self didSelectRange:self.selectedRange];
    }
    
    self.draggingStartDay = nil;
    [self animateMoveToAdjacentMonth:touchedView.day];
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
