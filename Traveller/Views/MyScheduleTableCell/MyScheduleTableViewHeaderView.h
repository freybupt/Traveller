//
//  MyScheduleTableViewHeaderView.h
//  Traveller
//
//  Created by Shirley on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyScheduleTableViewHeaderView : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *locationPinImageView;
@end
