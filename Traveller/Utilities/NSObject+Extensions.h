//
//  NSObject+Extensions.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extensions)
- (BOOL)isStringObject;
- (BOOL)isNumberObject;
- (BOOL)isArrayObject;
- (BOOL)isDictionaryObject;
- (BOOL)isDateObject;
- (BOOL)isURLObject;
- (BOOL)isMutableSetObject;
- (BOOL)isNonNullObject;
- (BOOL)isCityObject;
- (BOOL)isEventObject;
- (BOOL)isTripObject;
@end
