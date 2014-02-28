//
//  CalendarColorManager.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarColorManager.h"
#import "TripManager.h"

@interface CalendarColorManager ()

@property (nonatomic, strong) NSArray *defaultColorsArray;
@property (nonatomic, strong) UIColor *activeColor;

@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CalendarColorManager

+ (id)sharedManager
{
    static CalendarColorManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        //default color schemes
        manager.defaultColorsArray = [NSArray arrayWithObjects:
//                                      UIColorFromRGB(0xffffcc),
//                                      UIColorFromRGB(0xcccccc),
                                      UIColorFromRGB(0xcccc66),
                                      UIColorFromRGB(0x336666),
                                      UIColorFromRGB(0x339933),
                                      UIColorFromRGB(0x99cc00),
                                      UIColorFromRGB(0x9966),
                                      UIColorFromRGB(0xffff00),
                                      UIColorFromRGB(0xcc9966),
                                      UIColorFromRGB(0x3399cc),
                                      UIColorFromRGB(0x3366),
                                      UIColorFromRGB(0x99ccff),
                                      UIColorFromRGB(0x99cc33),
                                      nil];
    });
    return manager;
    
}

- (UIColor *)randomColor
{
    //give a random color
    NSInteger randIndex = arc4random()%[self.defaultColorsArray count];
    return [self.defaultColorsArray objectAtIndex:randIndex];
}

- (UIColor *)getActiveColor:(BOOL)shouldCreateNew
{
    if (self.activeColor == nil || shouldCreateNew) {
        //find a unique random color
        UIColor *uniqueColor;
        TripManager *tripManager = [TripManager sharedManager];
        NSArray *usedColors = [tripManager getUsedTripColors];
        BOOL shouldFindNextColor = YES;
        for (NSUInteger round = 0; round < [self.defaultColorsArray count] && shouldFindNextColor; round++) {
            uniqueColor = [self randomColor];
            shouldFindNextColor = NO;
            for (UIColor *usedColor in usedColors) {
                if ([usedColors isEqual:uniqueColor]) {
                    shouldFindNextColor = YES;
                }
            }
        }
        NSLog(@"Next Color: %@", uniqueColor);
        return  uniqueColor;
    }
    return self.activeColor;
}

- (UIColor *)getSelectionHighlightColor
{
    return [UIColor lightTextColor];
}

@end
