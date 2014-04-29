//
//  CarViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "CarViewController.h"

#define CAR_TABLEVIEWCELL_IDENTIFIER @"CarTableCellIdentifier"

@interface CarViewController ()

@end

@implementation CarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Car", nil);
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

#pragma mark - UITableView configuration
- (NSString *)tableCellReuseIdentifier
{
    return CAR_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - NSFetchedResultController configuration
- (NSString *)entityName
{
    return @"Car";
}

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
}

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rate" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

#pragma mark - Table view data source & delegate
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Car *car = (Car *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", car.model, car.year, car.reg_no, car.rate, car.currency];
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

    }
}
@end
