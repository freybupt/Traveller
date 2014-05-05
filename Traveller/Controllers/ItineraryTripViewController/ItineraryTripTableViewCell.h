//
//  ItineraryTripTableViewCell.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItineraryTripTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventTypeImageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@end
