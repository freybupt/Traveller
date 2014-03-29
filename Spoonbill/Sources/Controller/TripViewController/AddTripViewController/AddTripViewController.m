//
//  AddTripViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddTripViewController.h"

#define ADDTRIP_TABLEVIEWCELL_IDENTIFIER @"AddTripTableViewCellIdentifier"

@interface AddTripViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation AddTripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add Trip", nil);
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(backButtonTapAction:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(saveButtonTapAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        _managedObjectContext = [NSManagedObjectContext new];
        _managedObjectContext.undoManager = nil;
        _managedObjectContext.persistentStoreCoordinator = [[TripManager sharedInstance] persistentStoreCoordinator];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:ADDTRIP_TABLEVIEWCELL_IDENTIFIER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

#pragma mark - Button tap action
- (IBAction)backButtonTapAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)saveButtonTapAction:(id)sender
{
    /*
    if ([[TripManager sharedInstance] getCityWithCityName:[_detailTitles objectAtIndex:DetailTableRowCity]
                                                  context:_managedObjectContext]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"The city item has been saved before", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([[TripManager sharedInstance] addCityWithDictionary:[self cityDictionaryWithArray:_detailTitles]
                                                    context:_managedObjectContext]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TripManager", nil)
                                                            message:NSLocalizedString(@"An error just occurred when inserting a city item", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    */
}

#pragma mark - UITableView datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADDTRIP_TABLEVIEWCELL_IDENTIFIER
                                                                 forIndexPath:indexPath];
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = @"HELLO";
    /*
    cell.textField.tag = indexPath.row;
    cell.textField.delegate = self;
    
    switch (indexPath.section) {
        case AddCityTableSectionEditing:
            cell.textField.placeholder = NSLocalizedString([[[self cellTitles] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], nil);
            break;
        default:
            cell.textField.text = NSLocalizedString([[[self cellTitles] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], nil);
            break;
    }
    */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
