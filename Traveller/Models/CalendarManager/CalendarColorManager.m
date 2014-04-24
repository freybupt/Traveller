//
//  CalendarColorManager.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CalendarColorManager.h"
//#import "TripManager.h"

@interface CalendarColorManager ()

@property (nonatomic, strong) NSArray *defaultColorsArray;
@property (nonatomic, strong) UIColor *activeColor;

@end

@implementation CalendarColorManager

+ (id)sharedManager
{
    static CalendarColorManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        //default color schemes
        manager.defaultColorsArray = [NSArray arrayWithObjects:
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


- (UIColor *)nextColor
{
    //TODO: find adjacent color and avoid using them
    NSInteger index = [[TripManager sharedManager] countActiveTrips];
    return [self.defaultColorsArray objectAtIndex:index%([self.defaultColorsArray count])];
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
                if ([self isColor:usedColor theSameAsColor:uniqueColor]) {
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


- (BOOL)isColor:(UIColor *)color1 theSameAsColor:(UIColor *)color2
{
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate(colorSpaceRGB, components);
            UIColor *theColor = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            CGColorSpaceRelease(colorSpaceRGB);
            
            return theColor;
        } else
            return color;
    };
    
    UIColor *firstColor = convertColorToRGBSpace(color1);
    UIColor *secondColor = convertColorToRGBSpace(color2);

    return [firstColor isEqual:secondColor];
}

@end
