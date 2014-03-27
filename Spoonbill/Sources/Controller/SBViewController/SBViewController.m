//
//  SBViewController.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-26.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "SBViewController.h"

@interface SBViewController ()

@end

@implementation SBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Remove back button title */
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Title
- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.font = [UIFont systemFontOfSize:20.0f];
        titleView.textColor = [UIColor blackColor];
        self.navigationItem.titleView = titleView;
    }
    
    titleView.text = title;
    [titleView sizeToFit];
}
@end
