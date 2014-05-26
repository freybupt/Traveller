//
//  MyTripTableViewCell.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *attributedLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventTypeImageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, weak) IBOutlet UIView *flightDetail;

+ (NSAttributedString *)attributedString:(Trip *)trip;
@end
