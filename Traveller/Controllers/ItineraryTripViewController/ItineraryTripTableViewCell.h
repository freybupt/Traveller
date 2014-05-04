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
@end
