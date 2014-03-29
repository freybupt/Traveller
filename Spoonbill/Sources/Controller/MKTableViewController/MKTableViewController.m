//
//  MKTableViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MKTableViewController.h"

#define MK_TABLEVIEWCELL_IDENTIFIER @"MapKitTableCellIdentifier"

@interface MKTableViewController ()

@end

@implementation MKTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setMapView];
    [self setTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

#pragma mark - MKMapView configuration
- (void)setMapView
{
    // Overwrite subclass to implement other further map setup
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    // Overwrite subclass to implement other further table setup
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:[self tableCellReuseIdentifier]];
}

- (NSString *)tableCellReuseIdentifier
{
    // Overwrite subclass to implement different cell identifier
    return MK_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]
                                                            forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Overwrite subclass to implement appropriate actions
}

@end
