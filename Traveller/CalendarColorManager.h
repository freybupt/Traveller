//
//  CalendarColorManager.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CalendarColorManager : NSObject


+ (id)sharedManager;
- (UIColor *)randomColor;
//- (UIColor *)getActiveColor:(BOOL)shouldCreateNew;
- (UIColor *)getSelectionHighlightColor;

@end
