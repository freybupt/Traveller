//
//  ChangeOptionsViewController.m
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ChangeOptionsViewController.h"

@interface ChangeOptionsViewController ()
@property (nonatomic) BOOL isAConnectionOpen;

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
            //self.title = [self.trip.toEvent.eventType integerValue] == EventTypeHotel? @"HOTEL OPTIONS":@"FLIGHT OPTIONS";
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
    
    //This part is to avoid saturating the server with GET requests
    //TODO: comment or uncomment this section as needed
    BOOL isHotel = [self.trip.toEvent.eventType integerValue] == EventTypeHotel? YES:NO;
    if(isHotel){
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowHotels9" ofType:@"json"];
        NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ShowFlights166" ofType:@"json"];
        NSString *jsonDataInStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        serverData = [jsonDataInStr dataUsingEncoding:NSUTF8StringEncoding];
    }

    if (!serverData){
        serverData = [self sendGetRequest:self.trip];
    } else {
        NSArray *optionsFromServer = [self returnArrayOfEventsWith:serverData usingContext:[self managedObjectContext] sortedBy:@"duration"];
        NSLog(@"many options here....%@", optionsFromServer);
    }
}



- (NSData*) sendGetRequest:(Trip*)trip{
    UIAlertView *loadingMessage = [[UIAlertView alloc] initWithTitle: @"Loading" message: @"Please wait while your options load. This may take a few moments" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loadingMessage show];
    
    self.isAConnectionOpen = YES;
    NSString *tripType = [trip.toEvent.eventType integerValue] == EventTypeHotel? @"showHotels":@"showFlights";
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
-(NSArray*) returnArrayOfEventsWith:(NSData*)jsonData usingContext:(NSManagedObjectContext*)context sortedBy:(NSString*)sortingKey{
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
    NSString* jsonDicKey = [self.trip.toEvent.eventType integerValue] == EventTypeHotel? @"hotelList":@"flightList";
    NSArray *optionsFromServer = [[NSArray arrayWithObject:[jsonDic objectForKey:jsonDicKey]]objectAtIndex:0];
    //NSLog(@"%@", planSteps);
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey  ascending:YES];
    optionsFromServer=[optionsFromServer sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"this is it: %@",[optionsFromServer description]);
    
    //for (NSDictionary* option in optionsFromServer){
    //}
    
    //to test: the output must be equal to 3
    return optionsFromServer;
    
}



@end
