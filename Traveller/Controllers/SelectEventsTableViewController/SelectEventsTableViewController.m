//
//  SelectEventsTableViewController.m
//  Traveller
//
//  Created by Shirley on 2014-04-17.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "SelectEventsTableViewController.h"
#import "Checkbox.h"
#import "MZFormSheetController.h"
#import "SPGooglePlacesAutocompleteViewController.h"

#define TOPINSECT_FOR_EVENTTABLE 85.0f

@interface SelectEventsTableViewController () <MZFormSheetBackgroundWindowDelegate, UITextFieldDelegate>
{
    BOOL keyboardIsVisible;
    CGFloat keyboardHeight;
}
@property (nonatomic, strong) NSIndexPath *processingIndexPath;
@property (nonatomic) BOOL isAlertShown;
@end

@implementation SelectEventsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        keyboardIsVisible = NO;
        keyboardHeight = 0.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[TripManager sharedManager] setTripStage:TripStageSelectEvent];
    [self registerKeyboardNotification];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unregisterKeyboardNotification];
    [self hideActivityIndicator];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Button tap action
- (IBAction)checkBoxTapAction:(id)sender
{
    Checkbox *checkbox = (Checkbox *)sender;
    
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:checkbox.indexPath];
    event.isSelected = [NSNumber numberWithBool:checkbox.checked];
    [[DataManager sharedInstance] saveEvent:event
                                    context:self.managedObjectContext];
    MyScheduleTableCell *cell = (MyScheduleTableCell *)[self.tableView cellForRowAtIndexPath:checkbox.indexPath];
    if ([event.isSelected boolValue] &&
        [cell.eventLocationTextField.text length] == 0) {
        [cell.eventLocationTextField becomeFirstResponder];
    }
}

- (IBAction)editEventLocation:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    MyScheduleTableCell *cellView = (MyScheduleTableCell *)[[[gesture.view superview] superview] superview];
    _processingIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)cellView];
    [self performSegueWithIdentifier:@"editLocation" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editLocation"])
    {
        SPGooglePlacesAutocompleteViewController *vc = [segue destinationViewController];
        Event *eventToBeProcessed = [self.fetchedResultsController objectAtIndexPath:_processingIndexPath];
        if (eventToBeProcessed) {
            [vc setEvent:eventToBeProcessed];
            [vc setManagedObjectContext:self.managedObjectContext];
        }
    }
}

#pragma mark - NSFetchedResultController configuration
- (NSPredicate *)predicate
{
    return [NSPredicate predicateWithFormat:@"(uid == %@) AND (startDate >= %@) AND eventType = %@", [MockManager userid],
            [[NSDate date] dateAtMidnight],
            [NSNumber numberWithInt:0]];
}


#pragma mark - UITableViewDelegate
- (void)configureCell:(MyScheduleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.event = event;
    cell.eventTitleLabel.text = event.title;
    if ([event.allDay boolValue]) {
        cell.eventTimeLabel.text = NSLocalizedString(@"all-day", nil);
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        cell.eventTimeLabel.text = [formatter stringFromDate:event.startDate];
    }

    cell.locationImageView.hidden = ![event.isSelected boolValue];
    NSString* eventLocationTextFieldText = cell.eventLocationTextField.text;
    if(!eventLocationTextFieldText){
        cell.eventLocationTextField.text = (event.toCity) ? [NSString stringWithFormat:@"%@, %@",
                                                         event.toCity.cityName, event.toCity.countryName] : nil;
    }
    if ([event.isSelected boolValue]) {
        cell.backgroundColor = UIColorFromRGB(0xD0E5DB);
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.eventLocationTextField.autocompleteType = HTAutocompleteTypeCity;
    cell.eventLocationTextField.delegate = self;
    cell.eventLocationTextField.hidden = ![event.isSelected boolValue];
    
    [cell.eventLocationTextField setLeftViewMode:UITextFieldViewModeAlways];
    
    cell.eventLocationTextField.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earth16_mid"]];
    
    //TODO: optimize this part to use less internet
    if ([event.location length] > 0 && [event.isSelected boolValue]) {
        //let's try to add the geocode here
        NSString *currentLocationLabelText = cell.eventLocationLabel.text;
        if (!([currentLocationLabelText caseInsensitiveCompare:event.location]== NSOrderedSame) || !event.toCity){
            cell.eventLocationLabel.text = event.location;
            __block NSString* cityNameBlock;
            // perform geocode
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:event.location completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (placemarks.count>0){
                        
                        CLPlacemark *fullAddress = [placemarks firstObject];
                        NSDictionary *addressCorrected = fullAddress.addressDictionary;
                        NSLog(@"please %@", [addressCorrected description]);
                        
                        NSString *cityName = [addressCorrected objectForKey:@"City"];
                        cityNameBlock = cityName;
                        BOOL didCityChange = !([event.toCity.cityName caseInsensitiveCompare:cityName]== NSOrderedSame);
                        if(!event.toCity || didCityChange){
                            City *toCity = [[DataManager sharedInstance] getCityWithCityName:cityNameBlock
                                                                                     context:self.managedObjectContext];
                            //TODO: Ask Shirley about this...
                            if(!toCity){
                                toCity.cityName = [addressCorrected objectForKey:@"City"];
                                toCity.countryCode = [addressCorrected objectForKey:@"CountryCode"];
                                toCity.countryName = [addressCorrected objectForKey:@"Country"];
                                NSLog(@"Check that the city's fields are correct %@, %@, %@", [addressCorrected objectForKey:@"City"], [addressCorrected objectForKey:@"CountryCode"], [addressCorrected objectForKey:@"Country"]);
                                NSLog(@"this is the new city %@", [toCity description]);
                            } else {
                                NSLog(@"The city was found! How come? %@", toCity.cityName);
                            }
                            event.toCity = toCity;
                            
                            if(!([event.toCity.cityName caseInsensitiveCompare:cityName]== NSOrderedSame)){
                               // [self checkBoxTapAction:nil];
                               // [self checkBoxTapAction:nil];
                                //toCity.cityName = cityName;
                                //toCity.countryCode = [addressCorrected objectForKey:@"CountryCode"];
                           //     NSLog(@"check check check %@ =========== %@", toCity.cityName, cityName);
                            }
                           // NSLog(@"to city, please make sure that this is working %@ =========== %@", toCity.cityName, cityName);
                        }
                        //NSString *addressCorrectedStr = [[addressCorrected objectForKey:@"FormattedAddressLines"]description];
                        NSString *addressCorrectedStr = [[addressCorrected valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                        //NSLog(@"%@", addressCorrectedStr);
                        //NSString *newAddress = [fullAddress description];
                        if (!([cell.eventLocationTextField.text caseInsensitiveCompare:addressCorrectedStr]== NSOrderedSame)){
                            cell.eventLocationTextField.text = addressCorrectedStr;
                        }
                    }else if (placemarks.count == 0)
                    {
                        // show an alert if no results were found
                        
                        if (![self isAlertShown]){
                            UIAlertView *alert = [[UIAlertView alloc] init];
                            alert.title = @"No places were found for that location. Sorry about that";
                            [alert addButtonWithTitle:@"OK"];
                            self.isAlertShown = YES;
                            //TODO: change alertIsShown into false when the button is pressed
                            [alert show];
                        }
                    }
                }];
            if(cityNameBlock){
                City *toCity = [[DataManager sharedInstance] getCityWithCityName:cityNameBlock
                                                                         context:self.managedObjectContext];
                event.toCity = toCity;
                NSLog(@"check outside of the asynchronous function... %@ =========== %@", toCity.cityName, cityNameBlock);
            }
        }
  
    }
    else{
        cell.eventLocationLabel.text = @"Add an event address";
    }
    
    cell.locationView.hidden = ![event.isSelected boolValue]; // Include eventLocationLabel + imageView for edit12.png
    
    cell.checkBox.checked = [event.isSelected boolValue];
    [cell.checkBox addTarget:self action:@selector(checkBoxTapAction:) forControlEvents:UIControlEventValueChanged];
    cell.checkBox.indexPath = indexPath;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editEventLocation:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [cell.locationView addGestureRecognizer:singleTapGesture];
    [[DataManager sharedInstance] saveEvent:event
                                    context:self.managedObjectContext];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    _processingIndexPath = indexPath;
    
//    MyScheduleTableCell *cell = (MyScheduleTableCell *)[tableView cellForRowAtIndexPath:indexPath];
//    cell.checkBox.checked = !cell.checkBox.checked;
//    [self checkBoxTapAction:cell.checkBox];
    self.isAlertShown = NO;
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self editEventButtonTapAction:event];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (event && [event.isSelected boolValue]) {
        return 120.f;
    }
    else{
        return 50.f;
    }
}


//| ----------------------------------------------------------------------------
//  Because a custom accessory view is used, this method is never invoked by
//  the table view.  If one of the standard UITableViewCellAccessoryTypes were
//  used instead, the table view would invoke this method in response to a tap
//  on the accessory.
//
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}


//| ----------------------------------------------------------------------------
//! IBAction that is called when the value of a checkbox in any row changes.
//
- (IBAction)reviewDetail:(id)sender forEvent:(UIEvent*)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    // Lookup the index path of the cell whose checkbox was modified.
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    Event *anEvent = (Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self editEventButtonTapAction:anEvent];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGPoint position = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    _processingIndexPath = indexPath;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = [textField.text uppercaseStringToIndex:1];
    [textField resignFirstResponder];
    
    [self addToCityWithTextField:textField];
	
    return NO;
}

- (void)addToCityWithTextField:(UITextField *)textField
{
    if (!textField) {
        [self.tableView reloadRowsAtIndexPaths:@[_processingIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    NSArray *array = [textField.text componentsSeparatedByString:@", "];
    if ([array count] == 0) {
        [self.tableView reloadRowsAtIndexPaths:@[_processingIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    NSString *cityName = [[array objectAtIndex:0] uppercaseStringToIndex:1];
    City *toCity = [[DataManager sharedInstance] getCityWithCityName:cityName
                                                             context:self.managedObjectContext];
    if (!toCity) {
        [self.tableView reloadRowsAtIndexPaths:@[_processingIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }

    Event *anEvent = [self.fetchedResultsController objectAtIndexPath:_processingIndexPath];
    anEvent.toCity = toCity;
    anEvent.eventType = [NSNumber numberWithInteger:EventTypeDefault];
    [[DataManager sharedInstance] saveEvent:anEvent
                                    context:self.managedObjectContext];
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

#pragma mark -
#pragma mark Fetch events
- (void)fetchEvents
{
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:3600000000];
    NSArray *events = [[CalendarManager sharedManager] fetchEventsFromStartDate:startDate
                                                                      toEndDate:endDate];
        
    // Initialize the events list for synchronizing
    // Add events for those not in local storage
    for (EKEvent *event in events)
    {
        if ([[DataManager sharedInstance] getEventWithEventIdentifier:event.eventIdentifier
                                      context:self.managedObjectContext]) {
            [[DataManager sharedInstance] updateEventWithEKEvent:event
                                                      context:self.managedObjectContext];
        }
        else{
            [[DataManager sharedInstance] addEventWithEKEvent:event
                                                      context:self.managedObjectContext];
        }
    }
    
    // Remove events for those not in calendar
    [[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(Event *event, NSUInteger idx, BOOL *stop) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *ekEvent = [eventStore eventWithIdentifier:event.eventIdentifier];
        if (!ekEvent) {
            [self deleteEventButtonTapAction:event];
        }
    }];
    
    NSError *error = nil;
    [self.fetchedResultsController.fetchRequest setPredicate:[self predicate]];
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark EKEventEditViewDelegate
// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    SelectEventsTableViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:^{
        if (action == EKEventEditViewActionSaved &&
            controller.event) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf saveEventButtonTapAction:controller.event];
            });
        } else if (action == EKEventEditViewActionDeleted) {
            Event *event = [[DataManager sharedInstance] getEventWithEventIdentifier:controller.event.eventIdentifier
                                                                             context:self.managedObjectContext];
            [weakSelf deleteEventButtonTapAction:event];
        }
    }];
}

- (void)eventViewController:(EKEventViewController *)controller
      didCompleteWithAction:(EKEventViewAction)action
{
    SelectEventsTableViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:^{
        if (action == EKEventViewActionDone &&
            controller.event) {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            EKEvent *event = [eventStore eventWithIdentifier:controller.event.eventIdentifier];
            if (event) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf saveEventButtonTapAction:controller.event];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Event *event = [[DataManager sharedInstance] getEventWithEventIdentifier:controller.event.eventIdentifier
                                                                                     context:self.managedObjectContext];
                    [weakSelf deleteEventButtonTapAction:event];
                });
            }
        }
    }];
}

#pragma mark - NSNotificationCenter for keyboard
- (void)registerKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)unregisterKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (keyboardIsVisible) {
        return;
    }
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSTimeInterval duration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    keyboardHeight = keyboardFrameEndRect.size.height + TOPINSECT_FOR_EVENTTABLE;
    
    // Adjust frame when keyboard is opened
    [UIView transitionWithView:self.tableView
                      duration:duration options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.tableView.frame = CGRectMake(0.0f,
                                                          TOPINSECT_FOR_EVENTTABLE,
                                                          self.tableView.frame.size.width,
                                                          [UIScreen mainScreen].applicationFrame.size.height - keyboardHeight);
                    } completion:^(BOOL finished) {
                        if (finished) {
                            keyboardIsVisible = YES;
                            [self.tableView scrollToRowAtIndexPath:_processingIndexPath
                                                  atScrollPosition:UITableViewScrollPositionTop
                                                          animated:NO];
                        }
                    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!keyboardIsVisible) {
        return;
    }
    NSDictionary* keyboardInfo = [notification userInfo];
    
    NSTimeInterval duration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[keyboardInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    //Adjust frame when keyboard is closed
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        self.tableView.frame = CGRectMake(0.0f,
                                          TOPINSECT_FOR_EVENTTABLE,
                                          self.tableView.frame.size.width,
                                          [UIScreen mainScreen].applicationFrame.size.height - TOPINSECT_FOR_EVENTTABLE);
    }];
    keyboardIsVisible = NO;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if (!keyboardIsVisible) {
        return;
    }
    NSDictionary* keyboardInfo = [notification userInfo];
    NSTimeInterval duration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    keyboardHeight = keyboardFrameEndRect.size.height + TOPINSECT_FOR_EVENTTABLE;
    
    // Adjust frame when keyboard is opened
    [UIView transitionWithView:self.tableView
                      duration:duration options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.tableView.frame = CGRectMake(0.0f,
                                                          TOPINSECT_FOR_EVENTTABLE,
                                                          self.tableView.frame.size.width,
                                                          [UIScreen mainScreen].applicationFrame.size.height - keyboardHeight);
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [self.tableView scrollToRowAtIndexPath:_processingIndexPath
                                                  atScrollPosition:UITableViewScrollPositionTop
                                                          animated:NO];
                        }
                    }];
}

@end
