//
//  CityMapViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MKTableViewController.h"

@interface CityMapViewController : MKTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             withCity:(City *)city;
@end
