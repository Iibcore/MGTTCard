//
//  MGTTCardItem.h
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MGTTCardItemRemoveDirection) {
    MGTTCardItemRemoveDirectionLeft,
    MGTTCardItemRemoveDirectionRight
};

@class MGTTCardItem;

@protocol MGTTCardItemDelegate <NSObject>

- (void)cardItemWillBeginMove:(MGTTCardItem *)card;
- (void)cardItemBeginRemove:(MGTTCardItem *)card Direction:(MGTTCardItemRemoveDirection)direction;
- (void)cardItemRemoved:(MGTTCardItem *)card Direction:(MGTTCardItemRemoveDirection)direction;
- (void)cardItemDidClick:(MGTTCardItem *)card;
- (void)moveCardsX:(CGFloat)xDistance Y:(CGFloat)yDistance;
- (void)moveBackCards;
- (void)adjustOtherCards;

@end

@interface MGTTCardItem : UIView

@property (nonatomic, weak) id <MGTTCardItemDelegate>delegate;

@property (assign, nonatomic) CGPoint originalCenter;
@property (assign, nonatomic) CGAffineTransform originalTransform;

//标识
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) UIView *reuseView;

@end




