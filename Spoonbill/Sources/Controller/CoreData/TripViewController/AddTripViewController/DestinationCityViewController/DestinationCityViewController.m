//
//  DestinationCityViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DestinationCityViewController.h"

NSString * const TripOperationDidUpdateDestinationCityNotification = @"com.spoonbill.tripviewcontroller.operation.update.destinationcity";

@interface DestinationCityViewController ()

@end

@implementation DestinationCityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Destination City", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)backButtonTapAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source & delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    City *city = (City *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TripOperationDidUpdateDestinationCityNotification
                                                            object:city
                                                          userInfo:nil];
        [self backButtonTapAction:nil];
    });
}
@end
