//
//  ViewController.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//  MIT license
//

#import "PanoramaViewController.h"
#import "PanoramaView.h"

@interface PanoramaViewController (){
    PanoramaView *panoramaView;
}
@end

@implementation PanoramaViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [panoramaView setImage:@"hotel.jpg"];
    [panoramaView setOrientToDevice:YES];  // YES: use accel/gyro. NO: use touch pan gesture
    [panoramaView setPinchToZoom:YES];  // pinch to change field of view
    [panoramaView setShowTouches:NO];
    [self setView:panoramaView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapDetected:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(singleTapDetected:) withObject:self afterDelay:0.5];
}

- (void)singleTapDetected:(id)sender
{
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView draw];
}

@end