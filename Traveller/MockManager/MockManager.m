//
//  MockManager.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MockManager.h"

@implementation MockManager
+ (id)sharedInstance
{
    static MockManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MockManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
	if ((self = [super init]))
	{
        NSLog(@"Initializing Mock Manager");
	}
	return self;
}

+ (NSNumber *)userid
{
    return [NSNumber numberWithInteger:MOCK_USER_ID];
}
@end