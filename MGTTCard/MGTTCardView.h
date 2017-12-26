//
//  MGTTCardView.h
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGTTCardView;

@protocol MGTTCardViewDelegate <NSObject>

- (NSInteger)numberOfItemsInCardView:(MGTTCardView *)cardView;
- (UIView *)cardView:(MGTTCardView *)cardView viewForItemAtIndex:(NSInteger)index reuseView:(UIView *)reuseView;

@optional
- (void)cardView:(MGTTCardView *)cardView didSelectView:(UIView *)itemView atIndex:(NSInteger)index;

@end

typedef NS_ENUM(NSUInteger, MGTTCardViewStyle) {
    MGTTCardViewStyleTop,
//    MGTTCardViewStyleBottom,
//    MGTTCardViewStyleLeft,
//    MGTTCardViewStyleRight
};

@interface MGTTCardView : UIView

- (instancetype)initWithFrame:(CGRect)frame showNumberOfItems:(NSInteger)numbers style:(MGTTCardViewStyle)style;

@property (nonatomic, weak) id <MGTTCardViewDelegate>delegate;
- (void)reloadData;

@end
