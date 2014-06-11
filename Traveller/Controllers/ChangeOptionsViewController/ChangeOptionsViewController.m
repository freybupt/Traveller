//
//  ChangeOptionsViewController.m
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ChangeOptionsViewController.h"
#import "MyScheduleHotelTableCell.h"
#import "MyScheduleFlightTableCell.h"

static NSInteger kFlightCellFullHeight = 400;
static NSInteger kStandardCellHeight = 70;
static NSInteger kHotelCellFullHeight = 540;

@interface ChangeOptionsViewController ()
@property (nonatomic) BOOL isAConnectionOpen;
@property (nonatomic) BOOL isHotel;
@property (nonatomic) NSData* dataFromServer;
@property (nonatomic) NSArray* resultsFromServer;


-(NSData*)sendGetRequest:(Trip*)trip;
@end

@implementation ChangeOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.isAConnectionOpen){
        NSLog(@"connection started");
        if (self.trip){
            self.isHotel = [self.trip.toEvent.eventType integerValue] == EventTypeHotel? YES:NO;
            self.title = [self.trip.toEvent.eventType integerValue] == EventTypeHotel? @"HOTEL OPTIONS":@"FLIGHT OPTIONS";
            //NSData* serverResponse = [self sendGetRequest:self.trip];
            [self processEventChange:nil];
        } else {
            UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Invalid trip selected. Please go back to the previous screen" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMessage show];
            
        }
    }
    // Register self.managedObjectContext to share with CalendarDayView
    //[[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    [self hideActivityIndicator];
}
/*-(IBAction)calculateTrip:(id)sender {
 [self calculateTripFromClient:sender];
 [self calculateTripFromServer:sender usingResponse:nil];
 }*/

-(void)processEventChange:(NSData*)serverData{
    
    
    //TODO: Optimizing: change nsarray into a dictionary and use the keys for the ascending value/
    NSArray *sortingCriteria;
    if(self.isHotel){
        
        //This part is to avoid saturating the server with GET requests
        //TODO: comment or uncomment this section as needed
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowHotels9" ofType:@"json"];
        NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
        //END of section
        
        sortingCriteria = @[@"cost", @"hotelRating", @"userRating", @"cost", @YES, @NO, @NO, @YES];
        [self setSegmentedControlValuesAsHotel:YES];
    } else {
        
        //This part is to avoid saturating the server with GET requests
        //TODO: comment or uncomment this section as needed
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowFlights166" ofType:@"json"];
        NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
        //END of section
        
        sortingCriteria = @[@"cost", @"arrivalTime", @"departureTime", @"duration", @YES, @YES, @YES, @YES];
        [self setSegmentedControlValuesAsHotel:NO];
    }
    
    if (!serverData){
        serverData = [self sendGetRequest:self.trip];
        self.dataFromServer = serverData;
    } else {
        NSString *searchingCriteria = @"cost";
        BOOL ascending = YES;
        switch(self.criteriaSegmentedControl.selectedSegmentIndex){
            case 0:{
                searchingCriteria = [sortingCriteria objectAtIndex:0];
                ascending = [[sortingCriteria objectAtIndex:4]boolValue];
                break;
            }
            case 1:{
                searchingCriteria = [sortingCriteria objectAtIndex:1];
                ascending = [[sortingCriteria objectAtIndex:5]boolValue];
                break;
            }
            case 2:{
                searchingCriteria = [sortingCriteria objectAtIndex:2];
                ascending = [[sortingCriteria objectAtIndex:6]boolValue];
                break;
            }
            case 3:{
                searchingCriteria = [sortingCriteria objectAtIndex:3];
                ascending = [[sortingCriteria objectAtIndex:7]boolValue];
                break;
            }
            default:{
                searchingCriteria = [sortingCriteria objectAtIndex:0];
                ascending = YES;
                break;
            }
        }
        NSArray *optionsFromServer = [self returnArrayOfEventsWith:serverData usingContext:[self managedObjectContext] sortedBy:searchingCriteria inAscending:ascending];
        self.resultsFromServer = optionsFromServer;
    }
}



- (NSData*) sendGetRequest:(Trip*)trip{
    UIAlertView *loadingMessage = [[UIAlertView alloc] initWithTitle: @"Loading" message: @"Please wait while your options load. This may take a few moments" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loadingMessage show];
    
    self.isAConnectionOpen = YES;
    NSString *tripType = self.isHotel? @"showHotels":@"showFlights";
    NSString *tripServerID = [trip.toEvent.serverID stringValue];
    NSString *urlForGet = [NSString stringWithFormat:@"http://10.0.10.202:8182/%@/%@", tripType, tripServerID];
    NSLog(@"%@",urlForGet);
    
    //here is some code in case the JSON data needs to be displayed in the console
    
    /*
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSData *postData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
     */
    
    //create a request with the JSON data
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:urlForGet]];
    [request setHTTPMethod:@"GET"];
    
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
            self.isAConnectionOpen = NO;
            
        }
        else
        {
            [loadingMessage dismissWithClickedButtonIndex:0 animated:YES];
            responseAsync = data;
            //NSString *theReply = [[NSString alloc]initWithBytes:[responseAsync bytes] length:[responseAsync length] encoding:NSUTF8StringEncoding];
            // NSLog(@"\n\n\n\n %@", theReply); [self calculateTripFromServer:nil usingResponse:responseAsync];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Here are your possible options" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.isAConnectionOpen = NO;
            [self processEventChange:responseAsync];
            
        }
        
    }];
    return responseAsync;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmTripButtonTapAction:(id)sender
{
    [self showActivityIndicatorWithText:NSLocalizedString(@"Flight selected, going back", nil)];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Auxiliary functions
-(NSArray*) returnArrayOfEventsWith:(NSData*)jsonData usingContext:(NSManagedObjectContext*)context sortedBy:(NSString*)sortingKey inAscending:(BOOL)ascending{
    NSError *error;
    
    NSString *theReply = [[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"\n\n\n\n %@", theReply);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if([jsonDic objectForKey:@"Error Message"]){
        NSString* errorMessage = [jsonDic objectForKey:@"Error Message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!" message: errorMessage delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    NSString* jsonDicKey = self.isHotel? @"hotelList":@"flightList";
    NSArray *optionsFromServer = [[NSArray arrayWithObject:[jsonDic objectForKey:jsonDicKey]]objectAtIndex:0];
    //NSLog(@"%@", planSteps);
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey  ascending:ascending];
    optionsFromServer=[optionsFromServer sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"this is it: %@ sorted by %@",[optionsFromServer description], sortingKey);
    
    //for (NSDictionary* option in optionsFromServer){
    //}
    
    return optionsFromServer;
    
}

- (IBAction)changedCriteria:(id)sender{
    [self processEventChange:self.dataFromServer];
    [self.tableView reloadData];
}

-(void)setSegmentedControlValuesAsHotel:(BOOL)isHotel{
    if(isHotel){
        [self.criteriaSegmentedControl setTitle:@"cost" forSegmentAtIndex:0];
        [self.criteriaSegmentedControl setTitle:@"stars" forSegmentAtIndex:1];
        [self.criteriaSegmentedControl setTitle:@"rating" forSegmentAtIndex:2];
        [self.criteriaSegmentedControl setTitle:@"distance" forSegmentAtIndex:3];
    } else {
        [self.criteriaSegmentedControl setTitle:@"cost" forSegmentAtIndex:0];
        [self.criteriaSegmentedControl setTitle:@"arrive" forSegmentAtIndex:1];
        [self.criteriaSegmentedControl setTitle:@"depart" forSegmentAtIndex:2];
        [self.criteriaSegmentedControl setTitle:@"duration" forSegmentAtIndex:3];
    }
}

#pragma mark - Setting up the Table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyScheduleTableCell *tableCell;
    if (self.isHotel){
        NSDictionary *hotelProcessed = [self.resultsFromServer objectAtIndex:indexPath.row];
        MyScheduleHotelTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hotelCell"];
        if (!cell) {
            cell = [[MyScheduleHotelTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"hotelCell"];
        }
        cell.eventTitleLabel.text = [hotelProcessed objectForKey:@"hotelName"];
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"hotelIcon"]];
        cell.eventLocationLabel.text = [hotelProcessed objectForKey:@"address"];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", [[hotelProcessed objectForKey:@"cost"] floatValue] ];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [formatter dateFromString:[hotelProcessed objectForKey:@"startDate"]];
        NSDate *endDate = [formatter dateFromString:[hotelProcessed objectForKey:@"endDate"]];
        [formatter setDateFormat:@"MMM dd"];
        NSString *startDateStr = [formatter stringFromDate:startDate];
        NSString *endDateStr = [formatter stringFromDate:endDate];
        NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDateStr, @" - ",endDateStr];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.hotelDetailView.hidden = YES;
        //NSLog(@"this is start Date: %@ and please compare to the string: %@",startDate,[hotelProcessed objectForKey:@"startDate"]);
        
        cell.eventTimeLabel.text = fullDate;/*
        //set the detailed view checkin, checkout
        [formatter setDateFormat:@"EE, MMM dd"];
        startDate = [formatter stringFromDate:[hotelProcessed objectForKey:@"startDate"]];
        endDate = [formatter stringFromDate:[hotelProcessed objectForKey:@"endDate"]];
        cell.checkinLabel.text = startDate;
        cell.checkoutLabel.text = endDate;*/
        /*
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

         cell.contentView.backgroundColor = [UIColor whiteColor];
         
         cell.hotelDetailView.hidden = YES;*/
        
        tableCell = cell;
    } else {
        NSDictionary *flightProcessed = [self.resultsFromServer objectAtIndex:indexPath.row];
        MyScheduleFlightTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flightCell"];
        if (!cell) {
            cell = [[MyScheduleFlightTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                    reuseIdentifier:@"flightCell"];
        }
        cell.eventTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flight to %@", nil), [flightProcessed objectForKey:@"arrivalCity"]];
        int flightDuration = [[flightProcessed objectForKey:@"duration"] integerValue];
        NSNumber *durationHours = [NSNumber numberWithInt:floor(flightDuration/60)];
        NSNumber *remainingMinutes = [NSNumber numberWithInt:(flightDuration%60)];
        NSString *flightDurationStr = [durationHours stringValue];
        NSString *remainingMinutesStr = [remainingMinutes stringValue];
        int numOfStops = [[flightProcessed objectForKey:@"stops"]integerValue];
        NSString *numOfStopsStr;
        if(numOfStops ==0){
            numOfStopsStr = @"non-stop";
        } else {
            NSString *stopRaw = numOfStops==1? @" stop" : @" stops";
            NSString *numOfStopsStrInit = [NSString stringWithFormat:@"%d", numOfStops];
            numOfStopsStr = [NSString stringWithFormat:@"%@%@", numOfStopsStrInit, stopRaw];
        }
        
        NSString *timeString1 = [NSString stringWithFormat:@"%@%@%@%@%@", flightDurationStr, @"h "
                                 ,remainingMinutesStr,@"m \t\t\t\t",numOfStopsStr];
        cell.eventLocationLabel.text = timeString1;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", [[flightProcessed objectForKey:@"cost"] floatValue] ];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *startDate = [formatter dateFromString:[flightProcessed objectForKey:@"departureTime"]];
        NSDate *endDate = [formatter dateFromString:[flightProcessed objectForKey:@"arrivalTime"]];
        NSLog(@"these are the dates %@ and this %@", startDate, endDate);
        [formatter setDateFormat:@"HH:mm"];
        NSString *startDateStr = [formatter stringFromDate:startDate];
        NSString *endDateStr = [formatter stringFromDate:endDate];
        NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDateStr, @" - ",endDateStr];
        
        //set up the cell time fields
        cell.eventTimeLabel.text = fullDate;
        cell.departureTimeLabel.text = [NSString stringWithFormat:@"%@%@", startDate, @" departure"];
        cell.arrivalTimeLabel.text = [NSString stringWithFormat:@"%@%@", endDate, @" arrival"];

        
        
        cell.flightDetailView.hidden = YES;
        /*
        
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
            //TODO: add here the event that is currently selected.
            //This event must be set to a property, which will be later used to send it to the change options view contorller
            //The options view contrtoller will then process it to send it to the server................../
        }
        else{
            cell.flightDetailView.hidden = YES;
        }
        */
        tableCell = cell;
    }

    
    return tableCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   //TODO: rework this function
    return kStandardCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsFromServer count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

@end
