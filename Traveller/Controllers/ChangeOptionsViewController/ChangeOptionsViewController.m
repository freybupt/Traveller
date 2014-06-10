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

-(void)sendGetRequest:(Trip*)trip;
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
            [self sendGetRequest:self.trip];
        } else {
            UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Invalid trip selected. Please go back to the previous screen" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMessage show];
            
        }
    }
    // Register self.managedObjectContext to share with CalendarDayView
    //[[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    [self hideActivityIndicator];
}



//function: perform operations needed{
    //use sendGet to get a list of events from an eventID sent to the user
    //sort the events based on the current's tab description
    //display to the user the events based on the sorting algorithm
//}




- (void) sendGetRequest:(Trip*)trip{
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
    __block NSData *responseAsync;//right now it is being done synchronously
    
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
            NSString *theReply = [[NSString alloc]initWithBytes:[responseAsync bytes] length:[responseAsync length] encoding:NSUTF8StringEncoding];
            NSLog(@"\n\n\n\n %@", theReply);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Here are your possible options" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.isAConnectionOpen = NO;
            
        }
        
    }];
    
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

@end
