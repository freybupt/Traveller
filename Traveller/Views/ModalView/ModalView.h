//
//  ModalView.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-20.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MODAL_VIEW_PADDING 8.0f
#define TITLE_LABEL_HEIGHT 34.0f
#define BOTTOM_BUTTON_HEIGHT 45.0f
#define BOTTOM_LEFT_BUTTON_WIDTH 100.0f
#define BOTTOM_RIGHT_BUTTON_WIDTH 150.0f

typedef NS_ENUM(NSInteger, ModalViewButtonIndex) {
    ModalViewButtonCancelIndex = 0,
    ModalViewButtonFirstOtherIndex,
    ModalViewButtonIndexCount
};

@protocol ModalViewDelegate;

@interface ModalView : UIView
@property (nonatomic, weak) id<ModalViewDelegate>delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

- (void)show;
@end

@protocol ModalViewDelegate <NSObject>
@optional
- (void)modalView:(ModalView *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)willPresentModalView:(ModalView *)modalView;  // before animation and showing view
- (void)didPresentModalView:(ModalView *)modalView;  // after animation
- (void)modalView:(ModalView *)modalView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)modalView:(ModalView *)modalView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end

