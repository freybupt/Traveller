//
//  EventDetailViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "SBViewController.h"

@interface EventDetailViewController : SBViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withEvent:(Event *)event;
@end
