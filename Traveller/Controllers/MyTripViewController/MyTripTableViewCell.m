//
//  MyTripTableViewCell.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-04.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyTripTableViewCell.h"

@implementation MyTripTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSAttributedString *)attributedString:(Trip *)trip
{
    Event *event = trip.toEvent;
    NSString *topString = ([event.allDay boolValue]) ? NSLocalizedString(@"all-day", nil) : event ? [event.startDate timeWithDateFormat:@"HH:mm"] : [trip.startDate timeWithDateFormat:@"HH:mm"];
    NSString *middleString = (!event) ? [NSString stringWithFormat:NSLocalizedString(@"Flight to %@", nil), trip.toCityDestinationCity.cityName] : event.title;
    NSString *bottomString = !event ? [NSString stringWithFormat:NSLocalizedString(@"5h\tnon-stop\tAirCanada", nil)] : ([event.location length] > 0) ? event.location : [NSString stringWithFormat:@"%@, %@ - %@, %@", trip.toCityDepartureCity.cityName, trip.toCityDepartureCity.countryCode, event.toCity.cityName, event.toCity.countryCode];
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@", topString, middleString, bottomString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // Top line
    NSDictionary *attributeTopString = @{NSForegroundColorAttributeName: UIColorFromRGB(0x295661),
                                         NSBackgroundColorAttributeName: [UIColor clearColor],
                                         NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:13.0f]};
    [attributedString addAttributes:attributeTopString range:NSMakeRange(0, [topString length])];
    
    // Middle line
    NSDictionary *attributeMiddleString = @{NSForegroundColorAttributeName: UIColorFromRGB(0x295661),
                                            NSBackgroundColorAttributeName: [UIColor clearColor],
                                            NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:16.0f]};
    [attributedString addAttributes:attributeMiddleString range:NSMakeRange([topString length] + 1, [middleString length])];
    
    // Bottom line
    NSDictionary *attributeBottomString = @{NSForegroundColorAttributeName: [UIColor grayColor],
                                            NSBackgroundColorAttributeName: [UIColor clearColor],
                                            NSFontAttributeName: [UIFont fontWithName:@"Avenir-LightOblique" size:14.0f]};
    [attributedString addAttributes:attributeBottomString range:NSMakeRange([topString length] + 1 + [middleString length] + 1, [bottomString length])];
    
    // Arrow
    NSDictionary *attributeArrow = @{NSForegroundColorAttributeName: UIColorFromRGB(0x81C893),
                                     NSBackgroundColorAttributeName: [UIColor clearColor],
                                     NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:16.0f]};
    [attributedString addAttributes:attributeArrow range:[string rangeOfString:@"to"]];
    
    // Line space
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2.0f;
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, attributedString.length)];

    return attributedString;
}
@end
