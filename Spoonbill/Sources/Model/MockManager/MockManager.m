//
//  MockManager.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MockManager.h"
#import "CHCSVParser.h"

@interface MockManager ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedCityResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedCarResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIView *background;
@end

@implementation MockManager
+ (id)sharedInstance
{
    static MockManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MockManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
	if ((self = [super init]))
	{
        NSLog(@"Initializing Mock Manager");
        
        NSPersistentStoreCoordinator *coordinator = [[TripManager sharedInstance] persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [NSManagedObjectContext new];
            _managedObjectContext.undoManager = nil;
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
        /* Generate cities to core data */
        /*
        if ([[[self fetchedCityResultsController] fetchedObjects] count] == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self compilePresetCanadaCities];
            });
        }
        */
        
        /* Generate car models to core data */
        if ([[[self fetchedCarResultsController] fetchedObjects] count] == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self compilePresetCarModels];
            });
        }
        
    }
	return self;
}

/* Fake userid */
+ (NSNumber *)userid
{
    return [NSNumber numberWithInteger:MOCK_USER_ID];
}

#pragma mark - Preset Canada cities
- (void)compilePresetCanadaCities
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startPresetCVSCompiling];
    });
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CanadaCities" ofType:@"csv"];
    NSArray *array = [NSArray arrayWithContentsOfCSVFile:filePath];
    NSArray *keys = [array objectAtIndex:0];
    [array enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            NSMutableDictionary *mDictionary = [NSMutableDictionary new];
            [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                key = [key isEqualToString:@"Country"] ? @"CountryCode" : key;
                [mDictionary addEntriesFromDictionary:@{ key : [array objectAtIndex:idx]}];
            }];
            
            if ([mDictionary[@"City"] isStringObject]) {
                [mDictionary addEntriesFromDictionary:@{ @"CityCode" : ([mDictionary[@"City"] length] > MAX_LENGTH_OF_CITYCODE) ? [[mDictionary[@"City"] uppercaseString] substringToIndex:MAX_LENGTH_OF_CITYCODE] : mDictionary[@"City"] }];
            }
            
            if ([mDictionary[@"Latitude"] isStringObject]) {
                [mDictionary addEntriesFromDictionary:@{ @"LatitudeRef" : ([mDictionary[@"Latitude"] doubleValue] > 0) ? NSLocalizedString(@"North", nil) : NSLocalizedString(@"South", nil) }];
            }
            
            if ([mDictionary[@"Longitude"] isStringObject]) {
                [mDictionary addEntriesFromDictionary:@{ @"LongitudeRef" : ([mDictionary[@"Longitude"] doubleValue] > 0) ? NSLocalizedString(@"East", nil) : NSLocalizedString(@"West", nil) }];
            }
            
            [mDictionary addEntriesFromDictionary:@{ @"Country" : NSLocalizedString(@"Canada", nil) }];
            
            if ([MockManager userid]) {
                [mDictionary addEntriesFromDictionary:@{ @"id" : [MockManager userid] }];
            }
            
            [[TripManager sharedInstance] addCityWithDictionary:mDictionary context:_managedObjectContext];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPresetCVSCompiling];
    });
}

#pragma mark - Preset Car Models
- (void)compilePresetCarModels
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startPresetCVSCompiling];
    });
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CarRental" ofType:@"csv"];
    NSArray *array = [NSArray arrayWithContentsOfCSVFile:filePath];
    NSLog(@"%@", array);
    NSArray *keys = [array objectAtIndex:0];
    [array enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            NSMutableDictionary *mDictionary = [NSMutableDictionary new];
            [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                [mDictionary addEntriesFromDictionary:@{ key : [array objectAtIndex:idx]}];
            }];
            
            if ([MockManager userid]) {
                [mDictionary addEntriesFromDictionary:@{ @"id" : [MockManager userid] }];
            }
            
            [[TripManager sharedInstance] addCarWithDictionary:mDictionary context:_managedObjectContext];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPresetCVSCompiling];
    });
}

- (void)startPresetCVSCompiling
{
    if (!_background) {
        _background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _background.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.center = _background.center;
        [indicatorView startAnimating];
        [_background addSubview:indicatorView];
    }
    [[[UIApplication sharedApplication].delegate window] addSubview:_background];
}

- (void)stopPresetCVSCompiling
{
    [_background removeFromSuperview];
}

#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedCityResultsController
{
    if (_fetchedCityResultsController) {
        return _fetchedCityResultsController;
    }
    
	// Set up the fetched results controller if needed.
    _fetchedCityResultsController = [self newFetchedCityResultsController];
    
    NSError *error = nil;
    if (![_fetchedCityResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	return _fetchedCityResultsController;
}

- (NSFetchedResultsController *)newFetchedCityResultsController
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self cityEntityDescription]];
    [fetchRequest setSortDescriptors:[self sortCityDescriptors]];
    [fetchRequest setPredicate:[self predicate]];
    
    NSFetchedResultsController *fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
	return fetchedResultsController;
}

- (NSEntityDescription *)cityEntityDescription
{
    return [NSEntityDescription entityForName:@"City"
                       inManagedObjectContext:_managedObjectContext];
}

- (NSArray *)sortCityDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityName" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

- (NSFetchedResultsController *)fetchedCarResultsController
{
    if (_fetchedCarResultsController) {
        return _fetchedCarResultsController;
    }
    
	// Set up the fetched results controller if needed.
    _fetchedCarResultsController = [self newFetchedCarResultsController];
    
    NSError *error = nil;
    if (![_fetchedCarResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	return _fetchedCarResultsController;
}

- (NSFetchedResultsController *)newFetchedCarResultsController
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self carEntityDescription]];
    [fetchRequest setSortDescriptors:[self sortCarDescriptors]];
    [fetchRequest setPredicate:[self predicate]];
    
    NSFetchedResultsController *fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
	return fetchedResultsController;
}

- (NSEntityDescription *)carEntityDescription
{
    return [NSEntityDescription entityForName:@"Car"
                       inManagedObjectContext:_managedObjectContext];
}

- (NSArray *)sortCarDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rate" ascending:YES];
    return [[NSArray alloc] initWithObjects:sortDescriptor, nil];
}

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
}
@end