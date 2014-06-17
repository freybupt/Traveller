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
static NSInteger kHotelCellFullHeight = 490;

@interface ChangeOptionsViewController ()
@property (nonatomic) BOOL isAConnectionOpen;
@property (nonatomic) BOOL isHotel;
@property (nonatomic) NSData* dataFromServer;
@property (nonatomic, strong) NSIndexPath *expandedCellIndexPath;
@property (nonatomic) NSArray* resultsFromServer;
@property (nonatomic) NSDictionary* reselectedTrip;


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
            self.isHotel?[self.criteriaSegmentedControl insertSegmentWithTitle:@"comfort" atIndex:4 animated:NO]:nil;
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
    NSArray *sortingFields;
    NSArray *ascendingArray;
    //NSMutableDictionary *sortingCriteriaDic = [[NSMutableDictionary alloc] init];
    if(self.isHotel){
        
        //This part is to avoid saturating the server with GET requests
        //TODO: comment this section to use the server
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowHotels9" ofType:@"json"];
        NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
        //END of section
        sortingFields = @[@"cost", @"hotelRating", @"userRating", @"distance", @"overAllValue"];
        ascendingArray = @[@YES, @NO, @NO, @YES, @NO];
        
        //sortingCriteria = @[@"cost", @"hotelRating", @"userRating", @"distance", @YES, @NO, @NO, @YES];
        [self setSegmentedControlValuesAsHotel:YES];
    } else {
        
        //This part is to avoid saturating the server with GET requests
        //TODO: comment this section to use the server
        //NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowFlights166" ofType:@"json"];
        //NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        //serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
        //END of section
        
        sortingFields = @[@"cost", @"arrivalTime", @"departureTime", @"duration"];
        ascendingArray = @[@YES, @YES, @YES, @YES];
        //sortingCriteria = @[@"cost", @"arrivalTime", @"departureTime", @"duration", @YES, @YES, @YES, @YES];
        [self setSegmentedControlValuesAsHotel:NO];
    }

    
    if (!serverData){
        NSLog(@"data form server pls have sth %@", self.dataFromServer);
        serverData = [self sendGetRequest:self.trip];
    } else {
        NSString *searchingCriteria = @"cost";
        BOOL ascending = YES;
        int currentSegment = self.criteriaSegmentedControl.selectedSegmentIndex;
        searchingCriteria = [sortingFields objectAtIndex:currentSegment];
        ascending = [[ascendingArray objectAtIndex:currentSegment]boolValue];
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
    NSString *urlForGet;
    if (self.isHotel){
        //TODO: check again the effed time zone...
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *startDate = [dateFormat stringFromDate:trip.toEvent.startDate];
        NSString *endDate = [dateFormat stringFromDate:trip.toEvent.endDate];
        NSLog(@"check this out pls %@ and this %@ compared to original %@ and end %@", startDate, endDate, trip.toEvent.startDate,trip.toEvent.endDate);

        urlForGet = [NSString stringWithFormat:@"http://10.0.10.202:8182/%@/%@/%@/%@", tripType, tripServerID, startDate, endDate];
    } else {
        urlForGet = [NSString stringWithFormat:@"http://10.0.10.202:8182/%@/%@", tripType, tripServerID];
    }
    
    /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSDate *startDate = [formatter dateFromString:[flightProcessed objectForKey:@"departureTime"]];
     NSDate *endDate = [formatter dateFromString:[flightProcessed objectForKey:@"arrivalTime"]];
     NSLog(@"these are the dates %@ and this %@", startDate, endDate);
     [formatter setDateFormat:@"MMM dd - HH:mm"];
     NSString *startDateStr = [formatter stringFromDate:startDate];
     [formatter setDateFormat:@"HH:mm"];
     NSString *endDateStr = [formatter stringFromDate:endDate];
     NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDateStr, @" - ",endDateStr];
     
     //set up the cell time fields
     cell.eventTimeLabel.text = fullDate;
     cell.departureTimeLabel.text = [NSString stringWithFormat:@"%@%@", startDateStr, @" departure"];
     cell.arrivalTimeLabel.text = [NSString stringWithFormat:@"%@%@", endDateStr, @" arrival"];*/
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
        if (!data || !([NSJSONSerialization JSONObjectWithData:data
                                                      options:kNilOptions
                                                        error:&error] != nil))
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
            self.dataFromServer = data;
            //NSString *theReply = [[NSString alloc]initWithBytes:[responseAsync bytes] length:[responseAsync length] encoding:NSUTF8StringEncoding];
            // NSLog(@"\n\n\n\n %@", theReply); [self calculateTripFromServer:nil usingResponse:responseAsync];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Here are your possible options" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.isAConnectionOpen = NO;
            [self processEventChange:responseAsync];
            [self.tableView reloadData];
            
        }
        
    }];
    return responseAsync;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2) {
        switch (buttonIndex) {
            case 1:
            {
                if (self.isAConnectionOpen){
                    UIAlertView *connectionOpen = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                                                             message:@"Please wait until the connection is terminated"
                                                                            delegate:self
                                                                   cancelButtonTitle:nil
                                                                   otherButtonTitles: nil];
                    [connectionOpen show];
                    [self performSelector:@selector(dismissAlert:) withObject:connectionOpen afterDelay:2.0f];
                    break;
                }
                
                // TODO: Remove flights/hotel/rental car events (Set cascade delete rule for them)                
                break;
            }
            default:
                break;
        }
    }
}

-(void)dismissAlert:(UIAlertView *) alertView
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmTripButtonTapAction:(id)sender
{
    [self showActivityIndicatorWithText:NSLocalizedString(@"Option selected, going back", nil)];
    [self.delegate addItemViewController:self didFinishEnteringItem:self.reselectedTrip];
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
    if([jsonDic objectForKey:@"Error Message"]||!jsonDic){
        NSString* errorMessage = [jsonDic objectForKey:@"Error Message"];
        if (!jsonDic){
            errorMessage = @"No data received, try later!";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: errorMessage delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        
        float distance = [[hotelProcessed objectForKey:@"distance"]floatValue];
        NSString* distanceStr = [NSString stringWithFormat:@"%.2f km away", distance];
        cell.distanceLabel.text = distanceStr;
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
        //NSLog(@"this is start Date: %@ and please compare to the string: %@",startDate,[hotelProcessed objectForKey:@"startDate"]);
        
        cell.eventTimeLabel.text = fullDate;
        
        //set the detailed view checkin, checkout
        [formatter setDateFormat:@"EE, MMM dd"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        startDateStr = [formatter stringFromDate:startDate];
        endDateStr = [formatter stringFromDate:endDate];
        cell.checkinLabel.text = startDateStr;
        cell.checkoutLabel.text = endDateStr;
        
        NSString *address = [hotelProcessed objectForKey:@"address"];
        cell.eventLocationLabel.text = address;
        
        NSString *roomType = [hotelProcessed objectForKey:@"description"];
        NSString *roomPrice = [NSString stringWithFormat:@"$%.2f", [[hotelProcessed objectForKey:@"cost"] floatValue]/[[hotelProcessed objectForKey:@"stayDays"] floatValue]];
        NSString *roomDetails = [NSString stringWithFormat:@"%@", roomType];
        cell.roomTypeLabel.text = roomDetails;
        cell.priceDetailLabel.text = [NSString stringWithFormat:@"%@/night", roomPrice];

     
         cell.roomTypeLabel.text = roomDetails;
         
         //set up the review label
         NSString *stars = [hotelProcessed objectForKey:@"hotelRating"];
         NSString *starText = [NSString stringWithFormat:@"%@ %@", stars, [[hotelProcessed objectForKey:@"hotelRating"] integerValue]>1?@"stars":@"star"];
         float userRating = [[hotelProcessed objectForKey:@"userRating"]floatValue];
        NSString *ratingField = [NSString stringWithFormat:@"%@ / %.1f rating", starText, userRating];
         cell.reviewLabel.text = ratingField;
         
         //TODO: add the amenity and the phone label
         cell.amenitiesLabel.text = @"placeholder amenity";
         cell.phoneLabel.text = @"place holder phone";
        
        //Get the location
        NSString *location = [NSString stringWithFormat:@"%@%@%@%@%@", address, @", ",[hotelProcessed objectForKey:@"city"], @", ", [hotelProcessed objectForKey:@"country"]];
        cell.addressLabel.text = location;
        
        if ([indexPath isEqual:self.expandedCellIndexPath]){
            self.reselectedTrip = hotelProcessed;
            cell.hotelDetailView.hidden = NO;
        }
        else{
            cell.hotelDetailView.hidden = YES;
        }
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
        [formatter setDateFormat:@"MMM dd - HH:mm"];
        NSString *startDateStr = [formatter stringFromDate:startDate];
        [formatter setDateFormat:@"HH:mm"];
        NSString *endDateStr = [formatter stringFromDate:endDate];
        NSString *fullDate = [NSString stringWithFormat:@"%@%@%@", startDateStr, @" - ",endDateStr];
        
        //set up the cell time fields
        cell.eventTimeLabel.text = fullDate;
        cell.departureTimeLabel.text = [NSString stringWithFormat:@"%@%@", startDateStr, @" departure"];
        cell.arrivalTimeLabel.text = [NSString stringWithFormat:@"%@%@", endDateStr, @" arrival"];

        
        
        if ([indexPath isEqual:self.expandedCellIndexPath]){
            cell.flightDetailView.hidden = NO;
            self.reselectedTrip = flightProcessed;
        }
        else{
            cell.flightDetailView.hidden = YES;
        }
        
        
        NSArray *flights = [flightProcessed objectForKey:@"FlightConnections"];
        //TODO: use array to get the all the objects instead of just a random one...
        NSDictionary *firstFlight = [flights objectAtIndex:0];
        //set up the airport name and the code (code for example, is YVR)
        NSString *airline = [firstFlight objectForKey:@"airline"];
        NSString *classType = [flightProcessed objectForKey:@"classType"];
        NSString* departureAirportName = [firstFlight objectForKey:@"departureAirport"];
        NSString *departureCode = [firstFlight objectForKey:@"departureCode"];
        cell.departureAirportLabel.text = [NSString stringWithFormat:@"%@ (%@)", departureAirportName, departureCode];
        NSString* arrivalAirportName = [firstFlight objectForKey:@"arrivalAirport"];
        NSString *arrivalCode = [firstFlight objectForKey:@"arrivalCode"];
        cell.arrivalAirportLabel.text = [NSString stringWithFormat:@"%@ (%@)", arrivalAirportName, arrivalCode];
        NSString *timeString2 = [NSString stringWithFormat:@"%@h %@m \t\t %@", flightDurationStr,
                                 remainingMinutesStr,airline];
        int isBusiness = [classType caseInsensitiveCompare:@"business"] == NSOrderedSame ? 1 : 0;
        cell.airlineWithDurationLabel.text = timeString2;
        
        [cell.eventTypeImageView setImage:[UIImage imageNamed:@"flightIcon"]];
        cell.classSegmentedControl.selectedSegmentIndex = isBusiness;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        if ([indexPath isEqual:self.expandedCellIndexPath]){
            cell.flightDetailView.hidden = NO;
            //TODO: add here the event that is currently selected.
            //This event must be set to a property, which will be later used to send it to the change options view contorller
            //The options view contrtoller will then process it to send it to the server................../
        }
        else{
            cell.flightDetailView.hidden = YES;
        }
        tableCell = cell;
    }

    
    return tableCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.expandedCellIndexPath]) {
        if (self.isHotel){
            return kHotelCellFullHeight;
        } else {
            return kFlightCellFullHeight;
        }
    }
    return kStandardCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsFromServer count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *option = self.isHotel?@"hotel":@"flight";
    return [NSString stringWithFormat:@"Please select your ideal %@", option];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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

}

@end
