//
//  ChangeOptionsViewController.m
//  Traveller
//
//  Created by Alberto Rivera on 2014-06-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ChangeOptionsViewController.h"

@interface ChangeOptionsViewController ()

-(void)sendGetRequest;
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
    [self sendGetRequest];
    // Register self.managedObjectContext to share with CalendarDayView
    //[[DataManager sharedInstance] registerBridgedMoc:self.managedObjectContext];
    [self hideActivityIndicator];
}

- (void) sendGetRequest{
    UIAlertView *loadingMessage = [[UIAlertView alloc] initWithTitle: @"Loading" message: @"Please wait while your options load. This may take a few moments" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loadingMessage show];
    
    //here is some code in case the JSON data needs to be displayed in the console
    
    /*
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSData *postData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
     */
    
    //create a request with the JSON data
    NSString* theUrl = @"http://10.0.10.202:8182/showHotels/33";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:theUrl]];
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
            
        }
        else
        {
            [loadingMessage dismissWithClickedButtonIndex:0 animated:YES];
            responseAsync = data;
            NSString *theReply = [[NSString alloc]initWithBytes:[responseAsync bytes] length:[responseAsync length] encoding:NSUTF8StringEncoding];
            NSLog(@"\n\n\n\n %@", theReply);
            
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
