//
//  ItineraryViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ItineraryViewController.h"
#import "ItineraryTripViewController.h"

@interface ItineraryViewController ()

@end

@implementation ItineraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self awakeFromNib];
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
- (IBAction)cancelButtonTapAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - NSFetchedResultController configuration

- (NSString *)entityName
{
    return @"Itinerary";
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

- (NSString *)sectionNameKeyPath
{
    return @"date";
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    // Raw Date String -> NSDate
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    return [date timeWithDateFormat:@"EEE, MMM dd"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:68.0/255.0 blue:78.0/255.0 alpha:1.0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itineraryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"itineraryCell"];
    }
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Itinerary *itinerary = (Itinerary *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = itinerary.title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Itinerary *itinerary = (Itinerary *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    ItineraryTripViewController *vc = [[ItineraryTripViewController alloc] initWithNibName:@"ItineraryTripViewController"
                                                                      bundle:nil
                                                                   itinerary:itinerary];
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
        Itinerary *itinerary = (Itinerary *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataManager sharedInstance] deleteItineray:itinerary
                                             context:self.managedObjectContext];
    }
}
@end
