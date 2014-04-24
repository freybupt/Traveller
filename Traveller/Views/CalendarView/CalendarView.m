//
//  CalendarView.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarView.h"
#import "CalendarDayView.h"
#import "DSLCalendarMonthSelectorView.h"
#import "DSLCalendarView.h"
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
    CalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    self.draggingStartDay = touchedView.day;
    self.draggingFixedDay = touchedView.day;
    self.draggedOffStartDay = NO;
    
    self.editingTrip = nil;
    //already have trip
    
    Trip *activeTrip = [[TripManager sharedManager] findActiveTripByDate:touchedView.day.date];
    if (activeTrip) {
        [self.delegate calendarView:self shouldHighlightTrip:activeTrip];
        self.originalTrip = activeTrip;
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *startDate =
        [gregorian components:(NSDayCalendarUnit |
                               NSWeekdayCalendarUnit) fromDate:activeTrip.startDate];
        NSDateComponents *endDate =
        [gregorian components:(NSDayCalendarUnit |
                               NSWeekdayCalendarUnit) fromDate:activeTrip.endDate];
        self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
        if ([touchedView.day.date isEqualToDate:activeTrip.startDate] ||
            [touchedView.day.date isEqualToDate:activeTrip.endDate]) {
            self.editingTrip = activeTrip;
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
    
    CalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    //TODO: check within current range whether there is trip plan already?
    //modify current trip
    
    if (self.editingTrip) {
        DSLCalendarRange *newRange;
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *startDate =
        [gregorian components:(NSDayCalendarUnit |
                               NSWeekdayCalendarUnit) fromDate:self.editingTrip.startDate];
        NSDateComponents *endDate =
        [gregorian components:(NSDayCalendarUnit |
                               NSWeekdayCalendarUnit) fromDate:self.editingTrip.endDate];
        
        if ([touchedView.day.date compare:self.editingTrip.startDate] == NSOrderedAscending){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:endDate];
        }
        else if ([touchedView.day.date compare:self.editingTrip.endDate] == NSOrderedDescending) {
            newRange = [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:touchedView.day];
        }
        else if([self.draggingStartDay isEqual:self.editingTrip.startDate]){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:endDate];
        }
        else if([self.draggingStartDay isEqual:self.editingTrip.endDate]){
            newRange = [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:touchedView.day];
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
    
    CalendarDayView *touchedView = [self dayViewForTouches:touches];
    if (touchedView == nil) {
        self.draggingStartDay = nil;
        return;
    }
    
    if (self.editingTrip) {
        Trip *updatedTrip = self.editingTrip;
        updatedTrip.startDate = self.selectedRange.startDay.date;
        updatedTrip.endDate = self.selectedRange.endDay.date;
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
    
    if (!self.draggedOffStartDay && [self.draggingStartDay isEqual:touchedView.day]) {
        self.selectedRange = [[DSLCalendarRange alloc] initWithStartDay:touchedView.day endDay:touchedView.day];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)]) {
        [self.delegate calendarView:self didSelectRange:self.selectedRange];
    }
    
    self.draggingStartDay = nil;
    [self animateMoveToAdjacentMonth:touchedView.day];
}


- (CalendarDayView*)dayViewForTouches:(NSSet*)touches {
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
            if ([view isKindOfClass:[CalendarDayView class]]) {
                return (CalendarDayView *)view;
            }
            view = view.superview;
        }
    }
    
    return nil;
}
@end
