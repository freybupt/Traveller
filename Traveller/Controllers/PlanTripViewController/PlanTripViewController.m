//
//  PlanTripViewController.m
//  Traveller
//
//  Created by WEI-JEN TU on 5/01/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PlanTripViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "AddDestinationViewController.h"
#import "PanoramaViewController.h"
#import "MyScheduleHotelTableCell.h"
#import "MyScheduleFlightTableCell.h"
#import "AlertModalView.h"
#import "ChangeOptionsViewController.h"

static NSInteger kEventCellHeight = 80;
static NSInteger kFlightCellFullHeight = 400;
static NSInteger kHotelCellFullHeight = 540;


@interface PlanTripViewController () <MZFormSheetBackgroundWindowDelegate>
@property (nonatomic, strong) Itinerary *itinerary;
@property (nonatomic, strong) NSIndexPath *expandedCellIndexPath;
@property (nonatomic, assign) NSInteger totalPrice;
@property (nonatomic) int countAlertShown;
@property (nonatomic) Trip* tripToBeSentToTheServer;


@property (nonatomic, weak) IBOutlet UIView *bookTripView;
@property (nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property (nonatomic, weak) IBOutlet UIButton *bookTripButton;
@property (nonatomic, weak) IBOutlet UIButton *adjustListViewButton;

- (IBAction)confirmTripChange:(id)sender;
- (IBAction)cancelTripChange:(id)sender;
- (IBAction)deleteCurrentTrip:(id)sender;
- (IBAction)hotelUnneeded:(id)sender;

@end

@implementation PlanTripViewController
- (void)awakeFromNib
{
    _itinerary = [[DataManager sharedInstance] newItineraryWithContext:self.managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register self.managedObjectContext to share with CalendarDayView
    [[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    
    if ([[TripManager sharedManager] tripStage] == TripStageSelectEvent) {
        [self calculateTrip:nil];
    }
    else{
        [self hideActivityIndicator];
    }
    
    [self.destinationPanelView.confirmDestinationButton addTarget:self
                                                           action:@selector(confirmTripChange:)
                                                 forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.cancelEditDestinationButton addTarget:self
                                                              action:@selector(cancelTripChange:)
                                                    forControlEvents:UIControlEventTouchUpInside];
    [self.destinationPanelView.removeTripButton addTarget:self
                                                   action:@selector(deleteCurrentTrip:)
                                         forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)shrinkMyScheduleView
{
    if (self.isScheduleExpanded) {
        
        PlanTripViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kMyScheduleYCoordinate, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height - kMyScheduleYCoordinate)];
            [weakSelf.tableView setContentSize:CGSizeMake(weakSelf.tableView.contentSize.width, weakSelf.tableView.contentSize.height - weakSelf.bookTripView.frame.size.height)];
            weakSelf.bookTripView.hidden = YES;
        }];
        
        self.isScheduleExpanded = NO;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
    }
}

- (void)showFullMyScheduleView
{
    if (!self.isScheduleExpanded) {
        PlanTripViewController __weak *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.myScheduleView setFrame:CGRectMake(0, kNavigationBarHeight, weakSelf.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - weakSelf.navigationController.navigationBar.frame.size.height)];
            weakSelf.bookTripView.hidden = NO;
        }];
        [self.showCalendarButton setImage:[UIImage imageNamed:@"calendar53"] forState:UIControlStateNormal];
        [self.showMapButton setImage:[UIImage imageNamed:@"map35"] forState:UIControlStateNormal];
        self.isScheduleExpanded = YES;
        [self.expandButton setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
    }
}

//REMVED METHOD.
//This method was going to retrieve the province/state code by using reverse Geocode.
//the delay was deemed too large, so the method is not being used. Just here for reference.
/*
 - (void) getProvinceCodeFrom:(Location*)location withContext:(NSManagedObjectContext*)context{
 [location willAccessValueForKey:nil];
 NSString *address = [location valueForKey:@"address"];
 NSLog(@"%@",address);
 float latitude = [[location valueForKey:@"latitude"]floatValue];
 float longitude = [[location valueForKey:@"longitude"]floatValue];
 
 CLLocation* realLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
 
 CLGeocoder *gc = [[CLGeocoder alloc] init];
 [gc reverseGeocodeLocation:realLocation completionHandler:^(NSArray *placemark, NSError *error)
 {
 CLPlacemark *pm = placemark[0];
 NSLog(@"\n\n\n\n\n\n\n\n\n\n %@", pm.administrativeArea);
 }];
 NSLog(@"\n\n\n\n %f %f", latitude, longitude);
 
 }*/

#pragma mark - Communication with the server and JSON processing
//will create a dictionary with all the values that a city has
- (NSMutableDictionary*) cityToDictionary:(City*)startCity
                              withContext:(NSManagedObjectContext*)context
                            needStartCity:(BOOL)need {
    NSString *cityJsonName;
    NSString *countryJsonName;
    
    if(need){
        cityJsonName = @"startCity";
        countryJsonName = @"startCountry";
    } else {
        cityJsonName = @"city";
        countryJsonName = @"country";
    }
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    //will inspect all the city's attributes, and fill out a dictionary with the values
    for (NSAttributeDescription *attribute in [[startCity entity] properties]) {
        NSString *attributeName = attribute.name;
        if([attributeName isEqualToString:@"toLocation"]){
            continue;
            //method not used due to taking too long to make a request.
            //it will remain here just as a guide.
            //Location* locCity = [startCity valueForKey:@"toLocation"];
            //[self getProvinceCodeFrom: locCity withContext:context];
        }
        if(!([attributeName  isEqualToString:@"cityName"]||[attributeName  isEqualToString:@"countryName"]||[attributeName isEqualToString:@"countryCode"]))continue;
        if([attributeName isEqualToString:@"cityName"])attributeName = cityJsonName;
        else if([attributeName isEqualToString:@"countryName"]) attributeName = countryJsonName;
        id attributeValue = [startCity valueForKey:attribute.name];
        if (attributeValue) {
            [fields setObject:attributeValue forKey:attributeName];
        }
    }
    return fields;
}

//will convert an array of events into a dictionary with all the fields listed
//TODO: cleanup the function into a more manageable one.
- (NSMutableDictionary*) eventsToDictionary:(NSArray*)events withContext:(NSManagedObjectContext*)context{
    NSMutableArray *eventData = [[NSMutableArray alloc]init];
    int i = 0;
    //get each of the events
    for (Event *event in events){
        i++;
        NSMutableDictionary *eventFields = [NSMutableDictionary dictionary];
        if (event.location){
            [eventFields setObject:event.location forKey:@"address"];
        }
        //and fill out the dictionary with the different attributes
        for (NSAttributeDescription *attribute in [[event entity] properties]) {
            NSString *attributeName = attribute.name;
            
            if([attributeName isEqualToString:@"toCity"]){
                City *city = event.toCity;
                NSDictionary *cityDic = [self cityToDictionary:city withContext:context needStartCity:NO];
                [eventFields addEntriesFromDictionary:cityDic];
            }
            if([attributeName hasPrefix:@"to"])continue;
            if([attributeName hasSuffix:@"Date"]){
                NSDate *attributeValue = [event valueForKey:attribute.name];
                if (attributeValue) {
                    //convert Date into NSString
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString* dateStringModified = [dateFormatter stringFromDate:attributeValue];
                    [eventFields setObject:dateStringModified forKey:attributeName];
                }
                continue;
            }
            if([attributeName isEqualToString:@"uid"]){
                attributeName = @"eventID";
                id attributeValue = [event valueForKey:attribute.name];
                if (attributeValue) {
                    [eventFields setObject:attributeValue forKey:attributeName];
                }
            }
        }
        [eventData addObject:eventFields];
    }
    //return the dictionary!
    NSMutableDictionary *eventsDictionary = [NSMutableDictionary dictionary];
    [eventsDictionary setObject:eventData forKey:@"events"];
    NSLog(@"the events! %@", eventsDictionary);
    return eventsDictionary;
}

//will print the json representation of the cities + events listed
- (NSData*)printToJsonAtCity:(City*)startCity withEvents:(NSArray*)events atContext:(NSManagedObjectContext*)context{
    NSMutableDictionary *fields = [self cityToDictionary:startCity withContext:context needStartCity:YES];
    NSMutableDictionary *eventsDictionary = [self eventsToDictionary:events withContext:context];
    [fields addEntriesFromDictionary:eventsDictionary];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fields options:NSJSONWritingPrettyPrinted error:&error];
    
    //next line of code will just conver the DATA into its string representation
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@" json string %@", jsonString);
    return jsonData;
}

//will post the data using async connection
- (NSData*)postToServerAsync:(NSString*)url theJSONData:(NSData*)jsonData{
    UIAlertView *loadingMessage = [[UIAlertView alloc] initWithTitle: @"Loading" message: @"Please wait while your options load. This may take a few moments" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loadingMessage show];
    
    //here is some code in case the JSON data needs to be displayed in the console
    
    /*
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSData *postData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
     */
    
    //create a request with the JSON data
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    //create two block variables to store the response
    //__block NSError* errorMain;
    __block NSData *responseAsync;
    
    //use asynch connection to send a POST request
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!data)
        {
            [loadingMessage dismissWithClickedButtonIndex:0 animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!" message: @"No message received from the server." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        else
        {
            [loadingMessage dismissWithClickedButtonIndex:0 animated:YES];
            responseAsync = data;
            [self calculateTripFromServer:nil usingResponse:responseAsync];
            NSString *theReply = [[NSString alloc]initWithBytes:[responseAsync bytes] length:[responseAsync length] encoding:NSUTF8StringEncoding];
            NSLog(@"\n\n\n\n %@", theReply);
        
        }
        
    }];
    return responseAsync;
}


//synchronous function to post the json data to the server
//deprecated in favour of using the asynchronous function
/*
 - (NSData*)postToServer:(NSString*)url theJSONData:(NSData*)jsonData{
 //here is some code in case the JSON data needs to be displayed in the console
 
 
 // NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
 // NSData *postData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
 
 
 //create a request with the JSON data
 NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
 [request setURL:[NSURL URLWithString:url]];
 [request setHTTPMethod:@"POST"];
 [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
 [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [request setHTTPBody:jsonData];
 //prepare the response
 NSURLResponse *response;
 NSError* error;
 //do the request/response and print the data
 //right now it is being done synchronously
 NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
 //NSString *theReply = [[NSString alloc]initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding:NSUTF8StringEncoding];
 //NSLog(@"\n\n\n\n %@", theReply);
 return POSTReply;
 }
 */


//convert the JSONData into an array containing Trips and Events
-(NSArray*) createArrayOfEventsFrom:(NSData*)jsonData usingContext:(NSManagedObjectContext*)context{
    NSError *error;
    

    NSString *theReply = [[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"\n\n\n\n %@", theReply);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if([jsonDic objectForKey:@"Error Message"]){
        NSString* errorMessage = [jsonDic objectForKey:@"Error Message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!" message: errorMessage delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return nil;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Your best travelling options are being displayed now." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    NSArray *planSteps = [[NSArray arrayWithObject:[jsonDic objectForKey:@"planSteps"]]objectAtIndex:0];
    //NSLog(@"%@", planSteps);
    NSMutableArray *eventsWithTrips = [[NSMutableArray alloc]init];
    for (NSDictionary* step in planSteps){
        //create the event and trip
        Event *newEvent = [[DataManager sharedInstance] newEventWithContext:self.managedObjectContext];
        Trip *newTrip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        
        //use a date format to process the dates later on
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
        if([[step objectForKey:@"stepType"] isEqualToString:@"flight"]){
            
            //process the flight type of event, with all its attributes!
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *startDate = [dateFormat dateFromString:[step objectForKey:@"departureTime"]];
            NSDate *endDate = [dateFormat dateFromString:[step objectForKey:@"arrivalTime"]];
            //TODO: put more attention to the timezones...
            NSString *arrivalCityName = [step objectForKey:@"arrivalCity"];
            NSString *departureCityName = [step objectForKey:@"departureCity"];
            City *arrivalCity = [[DataManager sharedInstance] getCityWithCityName:arrivalCityName                                                                          context:self.managedObjectContext];
            City *departureCity = [[DataManager sharedInstance] getCityWithCityName:departureCityName                                                                          context:self.managedObjectContext];
            double price = [[step objectForKey:@"cost"]floatValue];
            NSNumber *stops = [step objectForKey:@"stops"];
            NSNumber *duration = [step objectForKey:@"duration"];
            NSNumber *IDFromServer = [step objectForKey:@"flightID"];
            NSArray *connections = [step objectForKey:@"FlightConnections"];
            NSString *classType = [step objectForKey:@"classType"];
            
            //FLIGHT SETUP
            NSMutableArray *flightArray = [[NSMutableArray alloc]init];
            for (int i =0; i<[connections count];i++){
                Flight *newFlight = [[DataManager sharedInstance] newFlightWithContext:self.managedObjectContext];
                [[DataManager sharedInstance]setFlight:newFlight withDictionary:[connections objectAtIndex:i]];
                [flightArray addObject:newFlight];
                NSLog(@"heherehe : %@", newFlight);
            }
            NSSet *flightSet = [[NSSet alloc]initWithArray:flightArray];
            
            //EVENT SETUP
            newEvent.eventType = [NSNumber numberWithInteger: EventTypeFlight];
            newEvent.startDate = startDate;
            newEvent.endDate = endDate;
            newEvent.toCity = arrivalCity;
            newEvent.toFlight = flightSet;
            newEvent.stops = stops;
            newEvent.serverID = IDFromServer;
            newEvent.classType = classType;
            
            //newEvent.title = airline;
            //toTrip not set!
            
            
            //TRIP SETUP
            newTrip.toCityDepartureCity = departureCity;
            newTrip.toCityDestinationCity = arrivalCity;
            newTrip.price = [NSNumber numberWithDouble:price];
            newTrip.startDate = startDate;
            //newTrip.title = airline;
            newTrip.endDate = endDate;
            newTrip.toEvent = newEvent;
            newTrip.duration = duration;
            

            
            
            
        } else if ([[step objectForKey:@"stepType"] isEqualToString:@"hotel"]){
            
            //process the hotel type of event!
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            NSDate *startDate = [dateFormat dateFromString:[step objectForKey:@"startDate"]];
            //has to be 12:59:59 I believe because of the time zone
            //TODO: check with shirley about the time zone
            [dateFormat setDateFormat:@"yyyy-MM-dd 23:59:59"];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSString *newDate = [dateFormat stringFromDate:startDate];
            NSLog(@"herererehe111111111 %@",newDate);
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            startDate = [dateFormat dateFromString:newDate];
            NSLog(@"herererehe222222 %@",startDate);
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            //LOCAL TIME ZONE HERE
            NSLog(@"this is the time zone: %@",[NSTimeZone localTimeZone]);
            // This is just so I can create a date from a string.
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *endDate = [dateFormat dateFromString:[step objectForKey:@"endDate"]];
            [dateFormat setDateFormat:@"yyyy-MM-dd 00:00:00"];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            newDate = [dateFormat stringFromDate:endDate];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            endDate = [dateFormat dateFromString:newDate];
            NSString *newEndDate = [dateFormat stringFromDate:endDate];
            endDate = [dateFormat dateFromString:newEndDate];
            NSLog(@"herererehe222222 %@",endDate);
            
            NSString *cityName = [step objectForKey:@"city"];
            City *city = [[DataManager sharedInstance] getCityWithCityName:cityName                                                                          context:self.managedObjectContext];
            double price = [[step objectForKey:@"cost"]floatValue];
            NSString *hotelName = [step objectForKey:@"hotelName"];
            //[NSString stringWithFormat:@"%@%@%@", startDate, @" - ",endDate];
            NSString *address = [step objectForKey:@"address"];
            NSString *eventCity = [step objectForKey:@"city"];
            NSString *countryCode= [step objectForKey:@"country"];
            NSString *location = [NSString stringWithFormat:@"%@%@%@%@%@", address, @", ",eventCity, @", ", countryCode];
            NSNumber *IDFromServer = [step objectForKey:@"hotelID"];
            NSArray *amenities = [step objectForKey:@"AddedValue"];
            NSNumber *rating = [step objectForKey:@"hotelRating"];
            NSNumber *duration = [step objectForKey:@"stayDays"];

            
            NSMutableArray *amenitiesArray = [[NSMutableArray alloc]init];
            for (int i =0; i<[amenities count];i++){
                Amenity *newAmenity = [[DataManager sharedInstance]newAmenityWithContext:self.managedObjectContext];
                //TODO: check with Lan about the fields to add them here
                [amenitiesArray addObject:newAmenity];
            }
            
            //EVENT SETUP
            newEvent.eventType = [NSNumber numberWithInteger: EventTypeHotel];
            newEvent.startDate = startDate;
            newEvent.serverID = IDFromServer;
            newEvent.endDate = endDate;
            newEvent.title = hotelName;
            newEvent.toCity = city;
            newEvent.location = location;
            //TODO: maybe change stops into something that can be both used as the stops and as the rating.
            newEvent.rating = rating;
            //to trip not set
            
            //TRIP SETUP
            newTrip.toCityDepartureCity = city;
            newTrip.toCityDestinationCity = city;
            newTrip.price = [NSNumber numberWithDouble:price];
            newTrip.startDate = startDate;
            newTrip.toEvent = newEvent;
            newTrip.title = hotelName;
            newTrip.endDate = endDate;
            newTrip.duration = duration;
        }
        //create a small array that contains the Event-Trip Pair (may be modified)
        NSArray* eventTripPair = [[NSArray alloc]initWithObjects:newEvent,newTrip,nil];
        [eventsWithTrips addObject:eventTripPair];
    }
    
    //to test: the output must be equal to 3
    NSLog(@"try the array length: %lu",(unsigned long)[eventsWithTrips count]);
    return eventsWithTrips;
    
}

#pragma mark - trip and event processing into UI
-(void) processTrips:(NSArray*)trips withContext:(NSManagedObjectContext*) context{
    //it will create the trips from an array of event-trip pairs
    for (NSArray *pairs in trips){
        Trip *trip = [pairs objectAtIndex:1];
        double price = [trip.price floatValue];
        self.totalPrice += price;
        trip.toItinerary = _itinerary;
        if ([[DataManager sharedInstance] saveTrip:trip
                                           context:self.managedObjectContext]) {
            _itinerary.date = trip.startDate;
            _itinerary.title = [NSString stringWithFormat:NSLocalizedString(@"Trip to %@", nil), trip.toEvent.toCity.cityName];
        }
    }
}

- (void) processEvents:(NSArray*)events withContext:(NSManagedObjectContext*) context{
    //it will create trips from an array of events (usually the ones user defined)
    for(Event* event in events){
        Trip *tripWithEvent = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        tripWithEvent.toCityDepartureCity = event.toCity;
        tripWithEvent.toCityDestinationCity = event.toCity;
        tripWithEvent.startDate = event.startDate;
        tripWithEvent.endDate = event.endDate;
        tripWithEvent.toEvent = event;
        tripWithEvent.price = [NSNumber numberWithInteger:0]; //a price of an event without a trip to back it off is cero
        tripWithEvent.toItinerary = _itinerary;
        if ([[DataManager sharedInstance] saveTrip:tripWithEvent
                                           context:self.managedObjectContext]) {
            _itinerary.date = tripWithEvent.startDate;
            _itinerary.title = [NSString stringWithFormat:NSLocalizedString(@"Event at %@", nil), event.toCity.cityName];
        }
        
    }
}



#pragma mark - UI IBAction

//will calculate the whole trip based on the users events.
-(IBAction)calculateTrip:(id)sender {
    [self calculateTripFromClient:sender];
    [self calculateTripFromServer:sender usingResponse:nil];
}

- (IBAction)calculateTripFromClient:(id)sender
{
    NSArray *events = [[DataManager sharedInstance] getEventWithSelected:YES
                                                                 context:self.managedObjectContext];
    if ([events count] == 0) {
        [self hideActivityIndicator];
        return;
    }
    
    //convert the events got from the user into trips
    [self processEvents:events withContext:self.managedObjectContext];
    //show the price in the UI
    self.totalPrice = 0;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"Total: $%ld", (long)self.totalPrice];
    [self hideActivityIndicator];
    [[TripManager sharedManager] setTripStage:TripStagePlanTrip];
}

- (IBAction)calculateTripFromServer:(id)sender usingResponse:(NSData*)jsonResponse
{
    NSArray *events = [[DataManager sharedInstance] getEventWithSelected:YES
                                                                 context:self.managedObjectContext];
    if ([events count] == 0) {
        [self hideActivityIndicator];
        return;
    }
    
    //get the JSON format based on the cities + current events
    NSString *cityName = @"Vancouver";
    City *departureCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                                    context:self.managedObjectContext];
    NSData *jsonDataOut = [self printToJsonAtCity:departureCity withEvents:events atContext:self.managedObjectContext];
    
    //This is a file in order to avoid requesting information from the server during testing periods to save time
    //TODO: comment or uncomment this section as needed
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ServerResponse" ofType:@"json"];
    NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    jsonResponse = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
    //END of section
    
    
    if(!jsonResponse){ //if there is nothing from the server, ask for it
        [self postToServerAsync:@"http://10.0.10.202:8182/plan" theJSONData:jsonDataOut];
    } else {
        //transform the jsonData into an array of event-trip pairs
        NSArray *stepsFromServer = [self createArrayOfEventsFrom:jsonResponse  usingContext:self.managedObjectContext];
        //Processing data in order to be displayed by the UI
        //Please note that the total price label and the itinerary is being changed inside these functions
        if (stepsFromServer)
        {
            [self processTrips:stepsFromServer withContext:self.managedObjectContext];
        }
    }
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"Total: $%ld", (long)self.totalPrice];
    [self.tableView reloadData];
    [self hideActivityIndicator];
    [[TripManager sharedManager] setTripStage:TripStagePlanTrip];
}

- (IBAction)confirmTripChange:(id)sender
{
    [self.destinationPanelView.destinationTextField resignFirstResponder];
    
    Trip *trip = nil;
    if (self.objectID) {
        trip = (Trip *)[self.managedObjectContext objectWithID:self.objectID];
    }
    if (!trip) {
        trip = [[DataManager sharedInstance] newTripWithContext:self.managedObjectContext];
        trip.startDate = self.currentDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = self.currentDateRange.endDay.date; // Trip's endDate has to be equal to actually selected end day
    }
    
    if ([self.destinationPanelView.destinationTextField.text length] > 0) {
        trip.title = self.destinationPanelView.destinationTextField.text;
        
        City *toCity = nil;
        NSArray *array = [self.destinationPanelView.destinationTextField.text componentsSeparatedByString:@", "];
        if ([array count] > 1) {
            NSString *cityName = [[array objectAtIndex:0] uppercaseStringToIndex:1];
            toCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                               context:self.managedObjectContext];
        }
        if (toCity) {
            trip.toCityDestinationCity = toCity;
        }
    }
    
    if (self.currentDateRange) {
        self.originalDateRange = [[DSLCalendarRange alloc] initWithStartDay:self.currentDateRange.startDay
                                                                     endDay:self.currentDateRange.endDay];
    }
    
    if ([[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext]) {
        [self hideDestinationPanel:nil];
    }
}

- (IBAction)cancelTripChange:(id)sender
{
    Trip *trip = nil;
    if (self.objectID) {
        trip = (Trip *)[self.managedObjectContext objectWithID:self.objectID];
    }
    if (trip) {
        trip.startDate = self.originalDateRange.startDay.date; // Trip's startDate has to be earlier than actually selected start day
        trip.endDate = self.originalDateRange.endDay.date; // Trip's endDate has to be equal to actually selected end day
        [[DataManager sharedInstance] saveTrip:trip context:self.managedObjectContext];
    }
    
    [self hideDestinationPanel:nil];
}


- (IBAction)deleteCurrentTrip:(id)sender
{
    AlertModalView *alertView = [[AlertModalView alloc] initWithTitle:nil
                                                              message:NSLocalizedString(@"Are you sure you want to remove this part of your trip?", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Remove", nil)
                                                     otherButtonTitle:NSLocalizedString(@"No, don't remove", nil)];
    [alertView show];
}

- (IBAction)confirmTripButtonTapAction:(id)sender
{
    [self showActivityIndicatorWithText:NSLocalizedString(@"Booking your trip...\n\nPlease feel free to close the app. \nThis might take a while.", nil)];
    
    [[TripManager sharedManager] setTripStage:TripStageBookTrip];
    
    if ([[DataManager sharedInstance] saveItinerary:_itinerary context:self.managedObjectContext]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
}


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.expandedCellIndexPath]) {
        Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        Event *event = trip.toEvent;
        
        //expand list item
        if ([event.eventType integerValue] == EventTypeFlight) {
            //flight
            return kFlightCellFullHeight;
        }
        else if ([event.eventType integerValue] == EventTypeHotel) {
            //hotel
            return kHotelCellFullHeight;
        }
        else{
            //calendar event
            return kEventCellHeight;
        }
    }
    else{
        return kEventCellHeight;
    }
}

#pragma mark - SET UP THE EVENT CELLS
//TODO: set up to be able to accommodate two cells or more in case the airplane has to do stops
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//display each cell as it dequeues and/or is created while scrolling through rows in your UITableView.
{
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    MyScheduleTableCell *tableCell;
    
    if ([event.eventType integerValue] == EventTypeHotel) {
        //Hotel
        MyScheduleHotelTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hotelCell"];
        if (!cell) {
            cell = [[MyScheduleHotelTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"hotelCell"];
        }
        cell.eventTitleLabel.text = event.title;
        if ([event.allDay boolValue]) {
            cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [formatter setDateFormat:@"MMM dd"];
            NSString *startDate = [formatter stringFromDate:event.startDate];
            NSString *endDate = [formatter stringFromDate:event.endDate];
            NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDate, @" - ",endDate];
            NSLog(@"this is the full Date %@ but originally it was %@", endDate, event.endDate);
            
            cell.eventTimeLabel.text = fullDate;
            //set the detailed view checkin, checkout
            [formatter setDateFormat:@"EE, MMM dd"];
            startDate = [formatter stringFromDate:event.startDate];
            endDate = [formatter stringFromDate:event.endDate];
            cell.checkinLabel.text = startDate;
            cell.checkoutLabel.text = endDate;
        }
        //set up the "address" label
        NSString *address = event.location;
        cell.addressLabel.text = address;
        
        //set up the "room" label
        //TODO: replace "superior suite" by the appropriate suiet from the server
        NSString *roomType = @"Superior Suite";
        NSString *roomPrice = [NSString stringWithFormat:@"$%.2f", [trip.price floatValue]/[trip.duration floatValue]];
        NSString *roomDetails = [NSString stringWithFormat:@"%@ - %@/night", roomType, roomPrice];
        cell.roomTypeLabel.text = roomDetails;
        
        //set up the review label
        NSString *rating = [event.rating stringValue];        
        NSString *reviewText = [NSString stringWithFormat:@"%@ %@", rating, [event.rating integerValue]>1?@"stars":@"star"];
        cell.reviewLabel.text = reviewText;
        
        //TODO: add the amenity and the phone label
        cell.amenitiesLabel.text = @"placeholder amenity";
        cell.phoneLabel.text = @"place holder phone";
        
        if ([event.location length] > 0) {
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
        }
        else if([event.toCity.cityName length] > 0){
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
        }
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", [trip.price floatValue]];
        
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon"]];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        if ([indexPath isEqual:self.expandedCellIndexPath]){
            cell.hotelDetailView.hidden = NO;
            self.tripToBeSentToTheServer = trip;
        }
        else{
            cell.hotelDetailView.hidden = YES;
        }
        
        tableCell = cell;
    }
    else if ([event.eventType integerValue]== EventTypeDefault){
        //Event
        MyScheduleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
        if (!cell) {
            cell = [[MyScheduleTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:@"eventCell"];
        }
        cell.eventTitleLabel.text = event.title;
        if ([event.allDay boolValue]) {
            cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd - HH:mm"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            cell.eventTimeLabel.text = [formatter stringFromDate:event ? event.startDate : trip.startDate];
        }
        if ([event.location length] > 0) {
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@", event.location];
        }
        else if([event.toCity.cityName length] > 0){
            cell.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
        }
        cell.priceLabel.text = @"";
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"eventIcon"]];
        cell.contentView.backgroundColor = UIColorFromRGB(0xF4F5F8);
        tableCell = cell;
    }
    
    
    if ([event.eventType integerValue]== EventTypeFlight) {
        //flight
        MyScheduleFlightTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flightCell"];
        if (!cell) {
            cell = [[MyScheduleFlightTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                    reuseIdentifier:@"flightCell"];
        }
        
        cell.eventTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flight to %@", nil), trip.toCityDestinationCity.cityName];
        int flightDuration = [trip.duration integerValue];
        NSNumber *durationHours = [NSNumber numberWithInt:floor(flightDuration/60)];
        NSNumber *remainingMinutes = [NSNumber numberWithInt:(flightDuration%60)];
        NSString *flightDurationStr = [durationHours stringValue];
        NSString *remainingMinutesStr = [remainingMinutes stringValue];
        NSNumber *numOfStops = event.stops;
        NSString *numOfStopsStr;
        if([numOfStops integerValue]==0){
            numOfStopsStr = @"non-stop";
        } else {
            NSString *stopRaw = [numOfStops integerValue]==1? @" stop" : @" stops";
           NSString *numOfStopsStrInit = [event.stops stringValue];
            numOfStopsStr = [NSString stringWithFormat:@"%@%@", numOfStopsStrInit, stopRaw];
        }
        
        NSString *timeString1 = [NSString stringWithFormat:@"%@%@%@%@%@", flightDurationStr, @"h "
                                ,remainingMinutesStr,@"m \t\t\t\t",numOfStopsStr];
        NSArray *flights = [event.toFlight allObjects];

        //TODO: use array to get the all the objects instead of just a random one...
        Flight *theFlight = [flights objectAtIndex:0];
        //set up the airport name and the code (code for example, is YVR)
        NSString *airline = theFlight.airline;
        NSString *classType = event.classType;
        NSString* departureAirportName = theFlight.departureAirport;
        NSString *departureCode = theFlight.departureCode;
        cell.departureAirportLabel.text = [NSString stringWithFormat:@"%@ (%@)", departureAirportName, departureCode];
        NSString* arrivalAirportName = theFlight.arrivalAirport;
        NSString *arrivalCode = theFlight.arrivalCode;
        cell.arrivalAirportLabel.text = [NSString stringWithFormat:@"%@ (%@)", arrivalAirportName, arrivalCode];
        NSString *timeString2 = [NSString stringWithFormat:@"%@h %@m \t\t %@", flightDurationStr,
                                 remainingMinutesStr,airline];
        int isBusiness = [classType caseInsensitiveCompare:@"business"] == NSOrderedSame ? 1 : 0;
        cell.eventLocationLabel.text = timeString1;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", [trip.price floatValue]];
        cell.airlineWithDurationLabel.text = timeString2;
        
        //use date formatter to specify how the date will be displayed
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *startDate = [formatter stringFromDate:event.startDate];
        NSString *endDate = [formatter stringFromDate:event.endDate];
        NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDate, @" - ",endDate];
        
        //set up the cell time fields
        cell.eventTimeLabel.text = fullDate;
        cell.departureTimeLabel.text = [NSString stringWithFormat:@"%@%@", startDate, @" departure"];
        cell.arrivalTimeLabel.text = [NSString stringWithFormat:@"%@%@", endDate, @" arrival"];
        
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon"]];
        cell.classSegmentedControl.selectedSegmentIndex = isBusiness;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        if ([indexPath isEqual:self.expandedCellIndexPath]){
            cell.flightDetailView.hidden = NO;
            self.tripToBeSentToTheServer = trip;
        }
        else{
            cell.flightDetailView.hidden = YES;
        }
        tableCell = cell;
    }
    
    
    
    return tableCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//handle taps
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Trip *trip = (Trip *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event = trip.toEvent;
    
    
    if (self.isScheduleExpanded) {
        if ([indexPath isEqual:self.expandedCellIndexPath]) {
            self.expandedCellIndexPath = nil;
        }
        else{
            self.expandedCellIndexPath = indexPath;
        }
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        //expand list item
        if ([event.eventType integerValue] == EventTypeFlight) {
            //flight
        }
        else if ([event.eventType integerValue] == EventTypeHotel) {
            //hotel
        }
        else{
            //calendar event
            [self editEventButtonTapAction:event];
        }
    }
    else{
        //hightlight item in calendar or map
        if ([event.eventType integerValue] == EventTypeFlight) {
            //flight
            PlanTripViewController __weak *weakSelf = self;
            City *city = trip.toCityDestinationCity;
            MKCoordinateRegion region;
            region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
            region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                               DEFAULT_MAP_COORDINATE_SPAN * weakSelf.mapView.frame.size.height/weakSelf.mapView.frame.size.width);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mapView setRegion:region animated:YES];
            });
        }
        else if (![event.eventType integerValue] == EventTypeFlight) {
            //update map
            PlanTripViewController __weak *weakSelf = self;
            City *city = event.toCity;
            MKCoordinateRegion region;
            region.center = CLLocationCoordinate2DMake([city.toLocation.latitude floatValue], [city.toLocation.longitude floatValue]);
            region.span = MKCoordinateSpanMake(DEFAULT_MAP_COORDINATE_SPAN,
                                               DEFAULT_MAP_COORDINATE_SPAN * weakSelf.mapView.frame.size.height/weakSelf.mapView.frame.size.width);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mapView setRegion:region animated:YES];
            });
        }
    }
    self.tripToBeSentToTheServer = trip;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                // TODO: Remove flights/hotel/rental car events (Set cascade delete rule for them)
                if ([[DataManager sharedInstance] deleteItineray:_itinerary
                                                         context:self.managedObjectContext]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
                break;
            }
            default:
                break;
        }
    } else if (alertView.tag ==2){
        switch(buttonIndex){
            case 1:
            {
                int previousPrice = self.totalPrice;
                float newPrice = previousPrice - [self.tripToBeSentToTheServer.price floatValue];
                NSInteger price = ceil(newPrice);
                self.totalPrice = price;
                self.totalPriceLabel.text = [NSString stringWithFormat:@"Total: $%d", price];
                [[DataManager sharedInstance]deleteTrip:[self tripToBeSentToTheServer] context:[self managedObjectContext]];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - Event detail views
- (void)showHotelPanoramaWithEvent: (Event *)event
{
    PanoramaViewController *vc = [[PanoramaViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = event.title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark Accessibility

//| ----------------------------------------------------------------------------
//! Utility method for configuring a cell's accessibilityValue based upon the
//! current checkbox state.
//
- (void)updateAccessibilityForCell:(UITableViewCell*)cell
{
    // The cell's accessibilityValue is the Checkbox's accessibilityValue.
    cell.accessibilityValue = cell.accessoryView.accessibilityValue;
}

#pragma mark - NSFetchedResultController configuration

- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"uid == %@ AND toItinerary = %@", [MockManager userid], _itinerary];
}

#pragma mark - ModalView delegate
- (void)modalView:(ModalView *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case ModalViewButtonCancelIndex: {
            NSArray *array = [self getActiveTripByDateRange:self.currentDateRange];
            if ([array count] == 0) {
                return;
            }
            Trip *trip = [array objectAtIndex:0];
            if ([[DataManager sharedInstance] deleteTrip:trip
                                                 context:self.managedObjectContext]) {
                [self hideDestinationPanel:nil];
            }
        } break;
        case ModalViewButtonFirstOtherIndex:
        break;
    }
}

#pragma mark - delete the hotel
- (IBAction)hotelUnneeded:(id)sender{
    //TODO: ask shirley about this
    UIAlertView *warningForDelete = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you don't need a hotel?", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Keep Hotel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Delete Hotel", nil), nil];
    warningForDelete.tag = 2;
    [warningForDelete show];
}


#pragma mark - Segue

@class ChangeOptionsViewController;
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"changeFlightSegue"]||[segue.identifier isEqualToString:@"changeHotelSegue"]){
        ChangeOptionsViewController *changeOptionsController = (ChangeOptionsViewController *)segue.destinationViewController;
        NSLog(@"aha");
        //TODO: decide whether to do it this way
        //([[DataManager sharedInstance] deleteTrip:self.tripToBeSentToTheServer
         //                                 context:self.managedObjectContext]);
        //[self.tableView reloadData];
        changeOptionsController.trip = self.tripToBeSentToTheServer;
    }
}
@end


