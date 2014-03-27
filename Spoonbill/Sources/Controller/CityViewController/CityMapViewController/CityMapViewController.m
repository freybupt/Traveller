//
//  CityMapViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CityMapViewController.h"

#define DEFAULT_MAP_COORDINATE_SPAN 0.1f
#define CITYMAP_TABLEVIEWCELL_IDENTIFIER @"CityMapTableCellIdentifier"

typedef NS_ENUM(NSInteger, CityInfoTableRow) {
    CityInfoTableRowName,
    CityInfoTableRowLatitude,
    CityInfoTableRowLongitude,
    CityInfoTableRowCount
};

@interface CityMapViewController ()
@property (nonatomic, strong) City *city;
@end

@implementation CityMapViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             withCity:(City *)city
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Location", nil);
        _city = city;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - MKMapView configuration
- (void)setMapView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MKCoordinateRegion region;
        region.center = CLLocationCoordinate2DMake([_city.latitude floatValue], [_city.longitude floatValue]);
        region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                           DEFAULT_MAP_COORDINATE_SPAN * self.mapView.frame.size.height/self.mapView.frame.size.width);
        [self.mapView setRegion:region animated:YES];
    });
}

#pragma mark - UITableView configuration
- (NSString *)tableCellReuseIdentifier
{
    return CITYMAP_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CityInfoTableRowCount;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CityInfoTableRowName:
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", _city.cityName, _city.countryName];
            break;
        case CityInfoTableRowLatitude:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", _city.latitudeRef, _city.latitude];
            break;
        case CityInfoTableRowLongitude:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", _city.longitudeRef, _city.longitude];
            break;
    }
}
@end
