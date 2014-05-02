//
//  DataManager.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DataManager.h"
#import "CalendarColorManager.h"

NSString * const DataManagerOperationDidDeleteEventNotification = @"com.spoonbill.datamanager.operation.delete.event";

@interface DataManager ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation DataManager
+ (id)sharedInstance
{
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
	if ((self = [super init]))
	{
        NSLog(@"Init Data Manager shared instance");
	}
	return self;
}

#pragma mark - CoreData setup
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TripDataStorage" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TripDataStorage.sqlite"];
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)deleteAllObjectsWithEntity:(NSEntityDescription *)entityDescription
                         inContext:(NSManagedObjectContext *)moc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        NSError *error;
        NSArray *items = [moc executeFetchRequest:fetchRequest
                                            error:&error];
        
        for (NSManagedObject *managedObject in items) {
            [moc deleteObject:managedObject];
            NSLog(@"%@ object deleted", entityDescription.name);
        }
        
        if (![moc save:&error]) {
            NSLog(@"Error deleting %@ - error:%@", entityDescription, error);
        }
    });
}

#pragma mark - Application's documents directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Bridged NSManagedObjectContext
- (void)registerBridgedMoc:(NSManagedObjectContext *)moc
{
    _managedObjectContext = moc;
}

- (NSManagedObjectContext *)bridgedMoc
{
    return _managedObjectContext;
}

#pragma mark - City
- (NSArray *)getCityWithUserid:(NSNumber *)userid
                       context:(NSManagedObjectContext *)moc
{
    if (!userid || !moc ) {
        return nil;
    }
    
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"City"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:pred];
    
    NSArray *fetchResult = [moc executeFetchRequest:fetchRequest
                                              error:&error];
    return fetchResult;
}

- (City *)getCityWithCityName:(NSString *)cityName
                      context:(NSManagedObjectContext *)moc
{
    if (!cityName || !moc ) {
        return nil;
    }
    
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"cityName == %@ AND uid == %@", cityName, [MockManager userid]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"City"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:pred];
    
    NSArray *fetchResult = [moc executeFetchRequest:fetchRequest
                                              error:&error];
    
    return fetchResult.count == 0 ? nil : [fetchResult lastObject];
}

- (BOOL)addCityWithDictionary:(NSDictionary *)dictionary
                      context:(NSManagedObjectContext *)moc
{
    if (!dictionary || !moc ) {
        return NO;
    }
    
    if ([self getCityWithCityName:dictionary[@"City"] context:moc]) {
        return NO;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City"
                                              inManagedObjectContext:moc];
    City *city = [[City alloc] initWithEntity:entity
               insertIntoManagedObjectContext:moc];
    
    [self setCity:city withDictionary:dictionary];
    
    Location *toLocation = [self newLocationWithContext:moc];
    [self setLocation:toLocation withDictionary:dictionary];
    city.toLocation = toLocation;
    
    return [self saveCity:city
                  context:moc];
}

- (BOOL)saveCity:(City *)city
         context:(NSManagedObjectContext *)moc
{
    if (!city || !moc ) {
        return NO;
    }

    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Saved a city: %@", city);
    return YES;
}

- (BOOL)deleteCity:(City *)city
           context:(NSManagedObjectContext *)moc
{
    if (!city || !moc) {
        return NO;
    }
    
    [moc deleteObject:city];
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Deleted a city");
    return YES;
}

- (void)setCity:(City *)city withDictionary:(NSDictionary *)dictionary
{
    if ([dictionary[@"id"] isNumberObject]) {
        city.uid = dictionary[@"id"];
    }
    
    if ([dictionary[@"City"] isStringObject]) {
        NSString *cityName = dictionary[@"City"];
        city.cityName = [cityName uppercaseStringToIndex:1];
    }
    
    if ([dictionary[@"CityCode"] isStringObject]) {
        city.cityCode = dictionary[@"CityCode"];
    }
    
    if ([dictionary[@"Country"] isStringObject]) {
        city.countryName  = dictionary[@"Country"];
    }
    
    if ([dictionary[@"CountryCode"] isStringObject]) {
        city.countryCode = [dictionary[@"CountryCode"] uppercaseString];
    }
}

#pragma mark - Event
- (Event *)newEventWithContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:moc];
    Event *event = [[Event alloc] initWithEntity:entity
               insertIntoManagedObjectContext:moc];
    event.title = NSLocalizedString(@"New Event", nil);
    event.uid = [MockManager userid];
    
    return event;
}

- (Event *)getEventWithEventIdentifier:(NSString *)eventIdentifier
                               context:(NSManagedObjectContext *)moc
{
    if (!eventIdentifier || !moc ) {
        return nil;
    }
    
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventIdentifier == %@ AND uid == %@", eventIdentifier, [MockManager userid]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Event"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:pred];
    
    NSArray *fetchResult = [moc executeFetchRequest:fetchRequest
                                              error:&error];
    
    return fetchResult.count == 0 ? nil : [fetchResult lastObject];
}

- (BOOL)addEventWithEKEvent:(EKEvent *)ekEvent
                    context:(NSManagedObjectContext *)moc
{
    if (!ekEvent || !moc ) {
        return NO;
    }
    
    if ([self getEventWithEventIdentifier:ekEvent.eventIdentifier
                                  context:moc]) {
        return NO;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:moc];
    Event *event = [[Event alloc] initWithEntity:entity
                  insertIntoManagedObjectContext:moc];
    [self setEvent:event withEKEvent:ekEvent];
    
    City *city = [self getCityWithCityName:event.location context:moc];
    if (city) {
        event.toCity = city;
    }
    
    return [self saveEvent:event
                   context:moc];
}

- (BOOL)updateEventWithEKEvent:(EKEvent *)ekEvent
                       context:(NSManagedObjectContext *)moc
{
    if (!ekEvent || !moc ) {
        return NO;
    }
    
    Event *event = [self getEventWithEventIdentifier:ekEvent.eventIdentifier
                                             context:moc];
    [self setEvent:event withEKEvent:ekEvent];
    
    return [self saveEvent:event
                   context:moc];
}

- (BOOL)saveEvent:(Event *)event
          context:(NSManagedObjectContext *)moc
{
    if (!event || !moc ) {
        return NO;
    }
    
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Saved an event: %@", event);
    return YES;
}

- (BOOL)deleteEvent:(Event *)event
            context:(NSManagedObjectContext *)moc
{
    if (!event || !moc) {
        return NO;
    }
    
    [moc deleteObject:event];
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Deleted an event");
    return YES;
}

- (void)setEvent:(Event *)event withEKEvent:(EKEvent *)ekEvent
{
    if ([[MockManager userid] isNumberObject]) {
        event.uid = [MockManager userid];
    }
    
    if ([ekEvent.eventIdentifier isStringObject]) {
        event.eventIdentifier = ekEvent.eventIdentifier;
    }
    
    if ([ekEvent.title isStringObject]) {
        event.title = ekEvent.title;
    }
    
    if ([ekEvent.location isStringObject]) {
        event.location = ekEvent.location;
    }
    
    event.allDay = [NSNumber numberWithBool:ekEvent.allDay];
    
    event.isSelected = event.isSelected ? event.isSelected : [NSNumber numberWithBool:NO];
    
    if ([ekEvent.startDate isDateObject]) {
        event.startDate = [ekEvent.startDate localDate];
    }
    
    if ([ekEvent.endDate isDateObject]) {
        event.endDate = [ekEvent.endDate localDate];
    }
    
    if ([ekEvent.URL isURLObject]) {
        event.url = [ekEvent.URL absoluteString];
    }
    
    if ([ekEvent.notes isStringObject]) {
        event.notes = ekEvent.notes;
    }
}

#pragma mark - Location
- (Location *)newLocationWithContext:(NSManagedObjectContext *)moc
{
    if (!moc) {
        return nil;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                              inManagedObjectContext:moc];
    Location *location = [[Location alloc] initWithEntity:entity
                           insertIntoManagedObjectContext:moc];
    location.uid = [MockManager userid];
    
    return location;
}

- (void)setLocation:(Location *)location withDictionary:(NSDictionary *)dictionary
{
    if ([dictionary[@"Latitude"] isNumberObject]) {
        location.latitude = dictionary[@"Latitude"];
    }
    
    if ([dictionary[@"Latitude"] isStringObject]) {
        location.latitude = [NSNumber numberWithDouble:[dictionary[@"Latitude"] doubleValue]];
    }
    
    if ([dictionary[@"LatitudeRef"] isStringObject]) {
        location.latitudeRef = dictionary[@"LatitudeRef"];
    }
    
    if ([dictionary[@"Longitude"] isNumberObject]) {
        location.longitude = dictionary[@"Longitude"];
    }
    
    if ([dictionary[@"Longitude"] isStringObject]) {
        location.longitude = [NSNumber numberWithDouble:[dictionary[@"Longitude"] doubleValue]];
    }
    
    if ([dictionary[@"LongitudeRef"] isStringObject]) {
        location.longitudeRef = dictionary[@"LongitudeRef"];
    }
    
    if ([dictionary[@"Address"] isStringObject]) {
        location.address = dictionary[@"Address"];
    }
}

- (BOOL)saveLocation:(Location *)location
         context:(NSManagedObjectContext *)moc
{
    if (!location || !moc ) {
        return NO;
    }
    
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Saved a trip: %@", location);
    return YES;
}

#pragma mark - Trip
- (NSArray *)getTripWithUserid:(NSNumber *)userid
                       context:(NSManagedObjectContext *)moc
{
    if (!userid || !moc ) {
        return nil;
    }
    
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid == %@", [MockManager userid]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Trip"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:pred];

    NSArray *fetchResult = [moc executeFetchRequest:fetchRequest
                                              error:&error];
    return fetchResult;
}

- (Trip *)getActiveTripByDate:(NSDate *)date
                       userid:(NSNumber *)userid
                      context:(NSManagedObjectContext *)moc
{
    if (!userid || !moc ) {
        return nil;
    }

    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(uid == %@) AND (startDate <= %@) AND (endDate >= %@)", [MockManager userid], date, date];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Trip"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:pred];
    
    NSArray *fetchResult = [moc executeFetchRequest:fetchRequest
                                              error:&error];
    if ([fetchResult count] == 1) {
        return [fetchResult objectAtIndex:0];
    }

    NSArray *array = [self getTripWithUserid:userid context:moc];
    for (Trip *trip in array) {
        if ([trip.startDate withinSameDayWith:date]) {
            return trip;
        }
    }
    return nil;
}

- (NSArray *)getActiveTripByDateRange:(DSLCalendarRange *)dateRange
                               userid:(NSNumber *)userid
                              context:(NSManagedObjectContext *)moc
{
    // Iterate each day to get the first trip
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [dateRange.startDay dateWithGMTZoneCalendar];
    NSDate *endDate = [dateRange.endDay dateWithGMTZoneCalendar];
    for (NSDate *date = startDate;
         [date compare:endDate] <= 0;
         date = [date dateByAddingTimeInterval:24 * 60 * 60] ) {
        Trip *trip = [[DataManager sharedInstance] getActiveTripByDate:date
                                                          userid:userid
                                                         context:moc];
        if (trip &&
            ![mArray containsObject:trip]) {
            [mArray addObject:trip];
        }
    }
    
    return mArray;
}

- (BOOL)saveTrip:(Trip *)trip
         context:(NSManagedObjectContext *)moc
{
    if (!trip || !moc ) {
        return NO;
    }
    
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Saved a trip: %@", trip);
    return YES;
}

- (BOOL)deleteTrip:(Trip *)trip
           context:(NSManagedObjectContext *)moc
{
    if (!trip || !moc) {
        return NO;
    }
    
    [moc deleteObject:trip];
    if ([moc hasChanges]) {
        
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    NSLog(@"Deleted a trip");
    return YES;
}

- (Trip *)newTripWithContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip"
                                              inManagedObjectContext:moc];
    Trip *trip = [[Trip alloc] initWithEntity:entity
               insertIntoManagedObjectContext:moc];
    trip.title = NSLocalizedString(@"New Trip", nil);
    trip.defaultColor = [NSKeyedArchiver archivedDataWithRootObject:[[CalendarColorManager sharedManager] getActiveColor:YES]];
    trip.uid = [MockManager userid];
    trip.isRoundTrip = [NSNumber numberWithBool:NO];
    
    return trip;
}

@end
