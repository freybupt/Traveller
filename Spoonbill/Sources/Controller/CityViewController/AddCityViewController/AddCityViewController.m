//
//  AddCityViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddCityViewController.h"
#import "AddCityTableViewCell.h"

#define ADDCITY_TABLEVIEWCELL_IDENTIFIER @"AddCityTableViewCellIdentifier"
#define CITYNAME_TEXTFIELD_PLACEHOLDER @"Please enter a city name here..."
#define MAX_LENGTH_OF_CITYCODE 2

typedef NS_ENUM(NSInteger, AddCityTableSection) {
    AddCityTableSectionEditing,
    AddCityTableSectionDetail,
    AddCityTableSectionCount
};

typedef NS_ENUM(NSInteger, NameTableRow) {
    NameTableRowTextField,
    NameTableRowCount
};

typedef NS_ENUM(NSInteger, DetailTableRow) {
    DetailTableRowCity,
    DetailTableRowCityCode,
    DetailTableRowCountry,
    DetailTableRowCountryCode,
    DetailTableRowLatitude,
    DetailTableRowLatitudeRef,
    DetailTableRowLongitude,
    DetailTableRowLongitudeRef,
    DetailTableRowCount
};

@interface AddCityViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *textFieldTitles;
@property (nonatomic, strong) NSArray *detailTitles;
@property (nonatomic, strong) CLGeocoder *geocoder;
@end

@implementation AddCityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add City", nil);
        
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
        
        _textFieldTitles = [self defaultTextFieldTitles];
        _detailTitles = [self defaultDetailTitles];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView registerClass:[AddCityTableViewCell class]
       forCellReuseIdentifier:ADDCITY_TABLEVIEWCELL_IDENTIFIER];
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
    [self stopGeocoderQuery];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)saveButtonTapAction:(id)sender
{
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
}

#pragma mark - UITableView datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDCITY_TABLEVIEWCELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self cellTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self cellTitles] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADDCITY_TABLEVIEWCELL_IDENTIFIER
                                                            forIndexPath:indexPath];
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(AddCityTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableView default data
- (NSArray *)cellTitles
{
    return @[_textFieldTitles,
             _detailTitles];
}

- (NSArray *)defaultTextFieldTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:NameTableRowCount];
    for (NSUInteger idx = 0; idx < NameTableRowCount; idx++) {
        switch (idx) {
            case NameTableRowTextField:
                [mArray insertObject:CITYNAME_TEXTFIELD_PLACEHOLDER atIndex:NameTableRowTextField];
                break;
        }
    }
    return mArray;
}

- (NSArray *)defaultDetailTitles
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:DetailTableRowCount];
    for (NSUInteger idx = 0; idx < DetailTableRowCount; idx++) {
        switch (idx) {
            case DetailTableRowCity:
                [mArray insertObject:@"City" atIndex:DetailTableRowCity];
                break;
            case DetailTableRowCityCode:
                [mArray insertObject:@"CityCode" atIndex:DetailTableRowCityCode];
                break;
            case DetailTableRowCountry:
                [mArray insertObject:@"Country" atIndex:DetailTableRowCountry];
                break;
            case DetailTableRowCountryCode:
                [mArray insertObject:@"CountryCode" atIndex:DetailTableRowCountryCode];
                break;
            case DetailTableRowLatitude:
                [mArray insertObject:@"Latitude" atIndex:DetailTableRowLatitude];
                break;
            case DetailTableRowLatitudeRef:
                [mArray insertObject:@"LatitudeRef" atIndex:DetailTableRowLatitudeRef];
                break;
            case DetailTableRowLongitude:
                [mArray insertObject:@"Longitude" atIndex:DetailTableRowLongitude];
                break;
            case DetailTableRowLongitudeRef:
                [mArray insertObject:@"LongitudeRef" atIndex:DetailTableRowLongitudeRef];
                break;
        }
    }
    return mArray;
}

- (NSArray *)detailTitlesWithPlacemark:(CLPlacemark *)placemark
{
    NSString *city = placemark.addressDictionary[@"City"];
    NSString *cityCode = [placemark.addressDictionary[@"City"] length] > MAX_LENGTH_OF_CITYCODE ? [[placemark.addressDictionary[@"City"] uppercaseString] substringToIndex:MAX_LENGTH_OF_CITYCODE] : placemark.addressDictionary[@"City"];
    NSString *country = placemark.addressDictionary[@"Country"];
    NSString *countryCode = placemark.addressDictionary[@"CountryCode"];
    NSString *latitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
    NSString *latitudeRef = placemark.location.coordinate.latitude > 0 ? NSLocalizedString(@"North", nil) : NSLocalizedString(@"South", nil);
    NSString *longitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
    NSString *longitudeRef = placemark.location.coordinate.longitude > 0 ? NSLocalizedString(@"East", nil) : NSLocalizedString(@"West", nil);
    
    return @[city,
             cityCode,
             country,
             countryCode,
             latitude,
             latitudeRef,
             longitude,
             longitudeRef];
}

#pragma mark - UITableView update
- (void)updateTableViewWithPlacemark:(CLPlacemark *)placemark
{
    if (![placemark.addressDictionary[@"City"] isStringObject]) {
        return;
    }
    
    if (![placemark.addressDictionary[@"Country"] isStringObject]) {
        return;
    }
    
    if (![placemark.addressDictionary[@"CountryCode"] isStringObject]) {
        return;
    }
    
    if (!placemark.location) {
        return;
    }
    
    _detailTitles = [self detailTitlesWithPlacemark:placemark];
    
    [_tableView beginUpdates];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:AddCityTableSectionDetail]
              withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
}

#pragma mark - Geocoder query
- (void)startGeocoderWithText:(NSString *)text
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _geocoder = [[LocationManager sharedInstance] getPlacemarkWithAddress:text
                                                                    block:^(CLPlacemark *placemark, NSError *error) {
                                                                        if (!error) {
                                                                            [self updateTableViewWithPlacemark:placemark];
                                                                            [self stopGeocoderQuery];
                                                                            self.navigationItem.rightBarButtonItem.enabled = YES;
                                                                        }
                                                                    }];
}

- (void)stopGeocoderQuery
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (_geocoder) {
        [_geocoder cancelGeocode];
        _geocoder = nil;
    }
}

#pragma mark - Helpers
- (NSDictionary *)cityDictionaryWithPlacemark:(CLPlacemark *)placemark
{
    NSString *city = placemark.addressDictionary[@"City"];
    NSString *cityCode = [placemark.addressDictionary[@"City"] length] > MAX_LENGTH_OF_CITYCODE ? [[placemark.addressDictionary[@"City"] uppercaseString] substringToIndex:MAX_LENGTH_OF_CITYCODE] : placemark.addressDictionary[@"City"];
    NSString *country = placemark.addressDictionary[@"Country"];
    NSString *countryCode = placemark.addressDictionary[@"CountryCode"];
    NSNumber *latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
    NSString *latitudeRef = placemark.location.coordinate.latitude > 0 ? NSLocalizedString(@"North", nil) : NSLocalizedString(@"South", nil);
    NSNumber *longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
    NSString *longitudeRef = placemark.location.coordinate.longitude > 0 ? NSLocalizedString(@"East", nil) : NSLocalizedString(@"West", nil);
    NSNumber *uid = [MockManager userid];
    
    return @{ @"City" : city,
              @"CityCode" : cityCode,
              @"Country" : country,
              @"CountryCode" : countryCode,
              @"Latitude" : latitude,
              @"LatitudeRef" : latitudeRef,
              @"Longitude" : longitude,
              @"LongitudeRef" : longitudeRef,
              @"id" : uid};
}

- (NSDictionary *)cityDictionaryWithArray:(NSArray *)array
{
    NSString *city = [array objectAtIndex:DetailTableRowCity];
    NSString *cityCode = [array objectAtIndex:DetailTableRowCityCode];
    NSString *country = [array objectAtIndex:DetailTableRowCountry];
    NSString *countryCode = [array objectAtIndex:DetailTableRowCountryCode];
    NSNumber *latitude = [NSNumber numberWithDouble:[[array objectAtIndex:DetailTableRowLatitude] doubleValue]];
    NSString *latitudeRef = [array objectAtIndex:DetailTableRowLatitudeRef];
    NSNumber *longitude = [NSNumber numberWithDouble:[[array objectAtIndex:DetailTableRowLongitude] doubleValue]];
    NSString *longitudeRef = [array objectAtIndex:DetailTableRowLongitudeRef];
    NSNumber *uid = [MockManager userid];
    
    return @{ @"City" : city,
              @"CityCode" : cityCode,
              @"Country" : country,
              @"CountryCode" : countryCode,
              @"Latitude" : latitude,
              @"LatitudeRef" : latitudeRef,
              @"Longitude" : longitude,
              @"LongitudeRef" : longitudeRef,
              @"id" : uid};
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self stopGeocoderQuery];
    return [textField.placeholder isEqualToString:NSLocalizedString(CITYNAME_TEXTFIELD_PLACEHOLDER, nil)];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [textField.placeholder isEqualToString:NSLocalizedString(CITYNAME_TEXTFIELD_PLACEHOLDER, nil)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        [self startGeocoderWithText:textField.text];
        textField.text = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
