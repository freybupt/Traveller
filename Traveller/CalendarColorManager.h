//
//  CalendarColorManager.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarColorManager : NSObject


+ (id)sharedManager;
- (UIColor *)randomColor;
- (UIColor *)getActiveColor:(BOOL)shouldCreateNew;
- (UIColor *)getSelectionHighlightColor;

@end