//
//  DestinationModalView.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-20.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ModalView.h"

@interface DestinationModalView : ModalView
- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle;
@end
