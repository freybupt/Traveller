//
//  CityViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CityViewController.h"
#import "AddCityViewController.h"
#import "CityMapViewController.h"

#define CITY_TABLEVIEWCELL_IDENTIFIER @"CityTableCellIdentifier"

@interface CityViewController ()

@end

@implementation CityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"City", nil);
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(addCityButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
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
- (IBAction)addCityButtonTapAction:(id)sender
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add City", nil)
                                                            message:NSLocalizedString(@"Internet is necessary to add city", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    AddCityViewController *vc = [[AddCityViewController alloc] initWithNibName:@"AddCityViewController"
                                                                        bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - UITableView configuration
- (NSString *)tableCellReuseIdentifier
{
    return CITY_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - NSFetchedResultController configuration
- (NSString *)entityName
{
    return @"City";
}

- (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:[self entityName]
                       inManagedObjectContext:self.managedObjectContext];
}

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
}

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityName" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

#pragma mark - Table view data source & delegate
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    City *city = (City *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@ (%@)", city.cityName, city.countryName, city.countryCode];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    City *city = (City *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    CityMapViewController *vc = [[CityMapViewController alloc] initWithNibName:@"CityMapViewController"
                                                                        bundle:nil
                                                                      withCity:city];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        City *city = (City *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[TripManager sharedInstance] deleteCity:city
                                         context:self.managedObjectContext];
    }
}
@end
