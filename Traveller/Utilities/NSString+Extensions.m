//
//  NSString+Extensions.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-23.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)
- (NSString *)uppercaseStringToIndex:(NSUInteger)to
{
    if (to >= [self length]) {
        return self;
    }
    
    NSString *upperChar = [[self substringToIndex:to] uppercaseString];
    NSString *restChar = [self substringFromIndex:to];
    
    return [NSString stringWithFormat:@"%@%@", upperChar, [restChar lowercaseString]];
}
@end
