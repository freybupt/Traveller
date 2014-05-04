//
//  TutorialViewController.m
//  Traveller
//
//  Created by Shirley on 2014-05-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSArray *tutorialTitleStrings;
@property (nonatomic, strong) NSArray *tutorialTextStrings;

@property (nonatomic, weak) IBOutlet UIView *textView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;


@end

@implementation TutorialViewController

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

    self.view.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapDetected:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
//    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
//    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
//    [self.view addGestureRecognizer:swipeDownGesture];
//    
//    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
//    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
//    [self.view addGestureRecognizer:swipeUpGesture];
    
    //load images
    self.pageImages = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"tutorial1.png"],
                       [UIImage imageNamed:@"tutorial2.png"],
                       [UIImage imageNamed:@"tutorial3.png"],
                       [UIImage imageNamed:@"tutorial4.png"],
                       nil];
    
    self.tutorialTitleStrings = [NSArray arrayWithObjects:
                                 @"CONVENIENCE",
                                 @"EFFICIENCY",
                                 @"PREDICTABILITY",
                                 @"COMFORT",
                                 nil];
    
    self.tutorialTextStrings = [NSArray arrayWithObjects:
                                 @"Sync events and contacts from your device and let us plan your next trip. Save more time for the real deal.",
                                 @"One click booking all your flight, hotel and rental car. Modify the plan at anytime and we will take care of the rest.",
                                 @"Your itinerary is always at the finger tip. We'll check all the changes so you don't need to, and only notify when it's necessary",
                                 @"Your comfort during trip is important. We will select non-stop flights and the nearest hotel to your destination.",
                                 nil];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TutorialCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(singleTapDetected:) withObject:self afterDelay:0.5];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TutorialViewController __weak *weakSelf = self;
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gesture, NSUInteger idx, BOOL *stop) {
        [weakSelf.view removeGestureRecognizer:gesture];
    }];
}

- (void)singleTapDetected:(id)sender
{
    TutorialViewController __weak *weakSelf = self;
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            weakSelf.textView.hidden = YES;
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            weakSelf.textView.hidden = NO;
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
}

//- (void)swipeDown:(id)sender
//{
//    if (self.navigationController.navigationBarHidden) {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }
//}
//
//- (void)swipeUp:(id)sender
//{
//    if (!self.navigationController.navigationBarHidden) {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TutorialCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithPatternImage:[self.pageImages objectAtIndex:indexPath.row]];
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            self.titleLabel.text = [self.tutorialTitleStrings objectAtIndex:indexPath.row];
            self.textLabel.text = [self.tutorialTextStrings objectAtIndex:indexPath.row];
            break;
        }
    }
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
