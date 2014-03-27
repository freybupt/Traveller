//
//  MKTableViewController.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SBViewController.h"

@interface MKTableViewController : SBViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
