//
//  TripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "TripViewController.h"
#import "AddTripViewController.h"

#define TRIP_TABLEVIEWCELL_IDENTIFIER @"TripTableCellIdentifier"

@interface TripViewController ()

@end

@implementation TripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trip", nil);
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(addButtonTapAction:)];
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
- (IBAction)addButtonTapAction:(id)sender
{
    AddTripViewController *vc = [[AddTripViewController alloc] initWithNibName:@"AddTripViewController"
                                                                        bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:^{}];
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    // Overwrite subclass to implement other further table setup
}

- (NSString *)tableCellReuseIdentifier
{
    return TRIP_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - NSFetchedResultController configuration
- (NSString *)entityName
{
    return @"Trip";
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

#pragma mark - Table view data source & delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self tableCellReuseIdentifier]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:[self tableCellReuseIdentifier]];
    }
    
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", trip.title];
    NSString *roundTripSymbol = [trip.isRoundTrip boolValue] ? @"<-->" : @"-->";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@", trip.toCityDepartureCity.cityName, roundTripSymbol, trip.toCityDestinationCity.cityName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[TripManager sharedInstance] deleteTrip:trip
                                         context:self.managedObjectContext];
    }
}
@end
