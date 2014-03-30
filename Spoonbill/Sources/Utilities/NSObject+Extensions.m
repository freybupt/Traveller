//
//  NSObject+Extensions.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)
- (BOOL)isStringObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSString class]];
}

- (BOOL)isNumberObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSNumber class]];
}

- (BOOL)isArrayObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSArray class]];
}

- (BOOL)isDictionaryObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSDictionary class]];
}

- (BOOL)isDateObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSDate class]];
}

- (BOOL)isURLObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[NSURL class]];
}

- (BOOL)isNonNullObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isCityObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[City class]];
}

- (BOOL)isEventObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[Event class]];
}

- (BOOL)isTripObject
{
    id object = self;
    if (object == [NSNull null]) {
        return NO;
    }
    
    return [object isKindOfClass:[Trip class]];
}
@end
