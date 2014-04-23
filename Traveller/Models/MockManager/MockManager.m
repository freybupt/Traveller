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
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
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
        
        NSPersistentStoreCoordinator *coordinator = [[DataManager sharedInstance] persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [NSManagedObjectContext new];
            _managedObjectContext.undoManager = nil;
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
        /* Generate units to core data */
        if ([[[self fetchedResultsController] fetchedObjects] count] == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self compilePresetCanadaCities];
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
        [self startPresetCityCompiling];
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
            
            [[DataManager sharedInstance] addCityWithDictionary:mDictionary context:_managedObjectContext];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPresetCityCompiling];
    });
}

- (void)startPresetCityCompiling
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

- (void)stopPresetCityCompiling
{
    [_background removeFromSuperview];
}

#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
	// Set up the fetched results controller if needed.
    _fetchedResultsController = [self newFetchedResultsController];
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	return _fetchedResultsController;
}

- (NSFetchedResultsController *)newFetchedResultsController
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityDescription]];
    [fetchRequest setSortDescriptors:[self sortDescriptors]];
    [fetchRequest setPredicate:[self predicate]];
    
    NSFetchedResultsController *fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
	return fetchedResultsController;
}

- (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:@"City"
                       inManagedObjectContext:_managedObjectContext];
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

@end