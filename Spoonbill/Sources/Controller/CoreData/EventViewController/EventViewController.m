//
//  EventViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-27.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "EventViewController.h"
#import "EventDetailViewController.h"
#import "ChooseCityViewController.h"

#define EVENT_TABLEVIEWCELL_IDENTIFIER @"EventTableCellIdentifier"

@interface EventViewController ()

@end

@implementation EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Event", nil);
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(addEventButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotificationCenter];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterNotificationCenter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button tap action
- (IBAction)addEventButtonTapAction:(id)sender
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
    
    ChooseCityViewController *vc = [[ChooseCityViewController alloc] initWithNibName:@"ChooseCityViewController"
                                                                        bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:^{}];
}

- (IBAction)eventDetailButtonTapAction:(Event *)event
{
    if (!event) {
        return;
    }
    
    EventDetailViewController *vc = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController"
                                                                                bundle:nil
                                                                             withEvent:event];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView configuration
- (void)setTableView
{
    // Overwrite subclass to implement other further table setup
}

- (NSString *)tableCellReuseIdentifier
{
    return EVENT_TABLEVIEWCELL_IDENTIFIER;
}

#pragma mark - NSFetchedResultController configuration
- (NSString *)entityName
{
    return @"Event";
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
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", event.title, event.location];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [event.startDate relativeTime], [event.endDate relativeTime]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self eventDetailButtonTapAction:event];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TripManagerOperationDidDeleteEventNotification
                                                                object:event
                                                              userInfo:nil];
        });
    }
}

#pragma mark - Notification action
- (IBAction)deleteEventNotificationAction:(NSNotification *)notification
{
    if (![notification.object isEventObject]) {
        return;
    }
    Event *event = (Event *)notification.object;
    [[TripManager sharedInstance] deleteEvent:event
                                      context:self.managedObjectContext];
}

#pragma mark - NSNotificationCenter
- (void)registerNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteEventNotificationAction:)
                                                 name:TripManagerOperationDidDeleteEventNotification
                                               object:nil];
}

- (void)unregisterNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TripManagerOperationDidDeleteEventNotification
                                                  object:nil];
}
@end
