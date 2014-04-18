//
//  MockManager.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MOCK_USER_ID 401

@interface MockManager : NSObject
+ (id)sharedInstance;
+ (NSNumber *)userid;
@end
