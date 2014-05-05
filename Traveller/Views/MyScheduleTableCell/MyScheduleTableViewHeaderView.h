//
//  MyScheduleTableViewHeaderView.h
//  Traveller
//
//  Created by Shirley on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyScheduleTableViewHeaderView : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UIImageView *locationPinImageView;
@end
