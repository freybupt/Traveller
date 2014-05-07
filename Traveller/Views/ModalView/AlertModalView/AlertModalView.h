//
//  AlertModalView.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-07.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ModalView.h"

@interface AlertModalView : ModalView
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle;
@end
