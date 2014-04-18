//
//  BookingTableViewController.m
//  Traveller
//
//  Created by Shirley on 2/25/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "BookingTableViewController.h"

#define NUM_TOP_ITEMS 20
#define NUM_SUBITEMS 5

@interface BookingTableViewController ()

@end

@implementation BookingTableViewController{
    NSArray *topItems;
    NSMutableArray *subItems; // array of arrays
    NSMutableArray *subItemsTitle;
    
    NSInteger currentExpandedIndex;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

#pragma mark - Data generators

- (NSArray *)topLevelItems {
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i = 10; i < NUM_TOP_ITEMS; i++) {
        [items addObject:[NSString stringWithFormat:@"Feb %d                                                    Destination", i + 1]];
    }
    
    [items replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"Feb 11                                                    Shanghai"]];
     [items replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"Feb 12                                                    Beijing"]];
    return items;
}

- (NSArray *)subItems {
    NSMutableArray *items = [NSMutableArray array];
    int numItems = NUM_SUBITEMS;
    
    for (int i = 0; i < numItems; i++) {
        [items addObject:[NSString stringWithFormat:@"Meeting with client"]];
    }
    
    [items replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"Vancouver -> Shanghai"]];
    [items replaceObjectAtIndex:1 withObject:@"I need to rent a car"];
    if (numItems > 2) {
        [items replaceObjectAtIndex:2 withObject:@"Kerry Hotel Pudong"];
    }
    
    return items;
}

- (NSArray *)subItemsTitle {
    NSMutableArray *items = [NSMutableArray array];
    int numItems = NUM_SUBITEMS;
    
    for (int i = 0; i < numItems; i++) {
        [items addObject:@"Meeting location"];
    }
    
    [items replaceObjectAtIndex:0 withObject:@"12h 45m     Nonstop        AirCanada"];
    [items replaceObjectAtIndex:1 withObject:@"1 hour and 30 min drive from airport to hotel"];
    if (numItems > 2) {
        [items replaceObjectAtIndex:2 withObject:@"Checkout Feb 16        5 nights"];
    }
    
    return items;
}

#pragma mark - View management

- (void)viewDidLoad {
    [super viewDidLoad];
    topItems = [[NSArray alloc] initWithArray:[self topLevelItems]];
    subItems = [NSMutableArray new];
    subItemsTitle = [NSMutableArray new];
    currentExpandedIndex = -1;
    
    for (int i = 0; i < [topItems count]; i++) {
        [subItems addObject:[self subItems]];
    }
    
    for (int i = 0; i < [topItems count]; i++) {
        [subItemsTitle addObject:[self subItemsTitle]];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topItems count] + ((currentExpandedIndex > -1) ? [[subItems objectAtIndex:currentExpandedIndex] count] : 0);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];

    
    if (isChild) {
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        cell.textLabel.textAlignment = NSTextAlignmentJustified;
        cell.backgroundColor = UIColorFromRGB(0xe4fae4);
        if ([cell.textLabel.text isEqualToString:@"Meeting with client"]) {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = UIColorFromRGB(0xFFFFFF);
        }
    }
    else {
        cell.backgroundColor = [UIColor lightTextColor];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12.0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    UITableViewCell *cell;
    
    if (isChild) {
        cell = [tableView dequeueReusableCellWithIdentifier:ChildCellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:32.0];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:ParentCellIdentifier];
        cell.backgroundColor = [UIColor lightTextColor];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0];
    }
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ParentCellIdentifier];
    }
    
    if (isChild) {
        cell.detailTextLabel.text = [[subItemsTitle objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1];
        cell.textLabel.text = [[subItems objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1];
    }
    else {
        NSInteger topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex)
        ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count]
        : indexPath.row;
        
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = [topItems objectAtIndex:topIndex];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    if (isChild) {
        return 52.0;
    }
    else {
        return 20.0f;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    if (isChild) {
        NSLog(@"A child was tapped, do what you will with it");
        return;
    }
    
    [self.tableView beginUpdates];
    
    if (currentExpandedIndex == indexPath.row) {
        [self collapseSubItemsAtIndex:currentExpandedIndex];
        currentExpandedIndex = -1;
    }
    else {
        
        BOOL shouldCollapse = currentExpandedIndex > -1;
        
        if (shouldCollapse) {
            [self collapseSubItemsAtIndex:currentExpandedIndex];
        }
        
        currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count] : indexPath.row;
        
        [self expandItemAtIndex:currentExpandedIndex];
    }
    
    [self.tableView endUpdates];
    
}

- (void)expandItemAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSArray *currentSubItems = [subItems objectAtIndex:index];
    NSInteger insertPos = index + 1;
    for (NSInteger i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSInteger i = index + 1; i <= index + [[subItems objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
