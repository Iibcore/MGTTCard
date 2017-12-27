//
//  MGTTCardView.m
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import "MGTTCardView.h"
#import "MGTTMacro.h"
#import "MGTTCardItem.h"

@interface MGTTCardView () <MGTTCardItemDelegate>

@property (strong, nonatomic) NSMutableArray *disPlayArray;//展示的数组
@property (nonatomic, strong) NSMutableArray *removeArray;//移出的数组
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger indexMax;

@property (nonatomic, strong) NSMutableArray *positionArray;
@property (assign, nonatomic) CGPoint lastCardCenter;
@property (assign, nonatomic) CGAffineTransform lastCardTransform;

/**
 *  基础数据
 */
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) NSInteger itemNumbers;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat itemRotationAngle;

/**
 *  重叠风格
 */
@property (nonatomic, assign) MGTTCardViewStyle style;


@end

@implementation MGTTCardView

- (instancetype)initWithFrame:(CGRect)frame showNumberOfItems:(NSInteger)numbers style:(MGTTCardViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        _itemNumbers = numbers + kMGTT_CardCacheNumber;
        [self initProperty];
        [self initItems];
    }
    return self;
}

- (void)initProperty {
    self.backgroundColor = [UIColor clearColor];
    self.disPlayArray = [NSMutableArray new];
    self.removeArray = [NSMutableArray new];
    self.positionArray = [NSMutableArray new];
    
    self.screenWidth = kMGTT_ScreenWidth;
    self.screenHeight = kMGTT_ScreenHeight;
    self.itemScale = kMGTT_CardScale;
    self.itemRotationAngle = kMGTT_CardRotationAngle;
    
    self.itemWidth = self.frame.size.width;
    self.itemHeight = self.frame.size.height;
    
    self.index = 0;
}

- (void)initItems {
    if (!self.itemNumbers) {
        return;
    }
    //init
    for (NSInteger i = 0; i < self.itemNumbers; i++) {
        MGTTCardItem * card = [[MGTTCardItem alloc] initWithFrame:CGRectMake(0, 0, self.itemWidth, self.itemHeight)];
        
        if (i > 0 && i < self.itemNumbers - kMGTT_CardCacheNumber) {
            card.transform = CGAffineTransformScale(card.transform, pow(self.itemScale, i), pow(self.itemScale, i));
        } else if (i >= self.itemNumbers - kMGTT_CardCacheNumber) {
            card.transform = CGAffineTransformScale(card.transform, pow(self.itemScale, i - 1), pow(self.itemScale, i - 1));
        }
        card.transform = CGAffineTransformMakeRotation(self.itemRotationAngle);
        card.delegate = self;
        
        [self.disPlayArray addObject:card];
        if (i == 0) {
            card.userInteractionEnabled = YES;
        } else {
            card.userInteractionEnabled = NO;
        }
    }
    //add
    for (NSInteger i = self.itemNumbers - 1; i >= 0; i--) {
        [self addSubview:self.disPlayArray[i]];
    }
    //layout
    for (NSInteger i = 0; i < self.disPlayArray.count; i++) {
        MGTTCardItem *card = self.disPlayArray[i];
        CGPoint finishPoint = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
        card.center = finishPoint;
        card.transform = CGAffineTransformMakeRotation(0);
        card.alpha = 1;
        if (i > 0 && i < self.disPlayArray.count - kMGTT_CardCacheNumber) {
            //前面一张卡片
            MGTTCardItem *preCard = [self.disPlayArray objectAtIndex:i - 1];
            card.transform = CGAffineTransformScale(card.transform, pow(self.itemScale, i), pow(self.itemScale, i));
            CGRect frame = card.frame;
            frame.origin.y = preCard.frame.origin.y - (preCard.frame.size.height -frame.size.height);
            card.frame = frame;
            card.alpha = preCard.alpha - 0.25;
        } else if (i >= self.disPlayArray.count - kMGTT_CardCacheNumber) {
            //最后一张卡片与前一张一样
            MGTTCardItem *preCard = [self.disPlayArray objectAtIndex:i - 1];
            card.transform = preCard.transform;
            card.frame = preCard.frame;
            card.alpha = 0;
        }
        
        card.originalCenter = card.center;
        card.originalTransform = card.transform;
        [self.positionArray addObject:@{@"originalCenter" : [self valueWithCGPointStruct:card.center], @"originalTransform" : [self valueWithCGAffineTransformStruct:card.transform], @"alpha" : @(card.alpha)}];
        
        if (i == self.itemNumbers - 1) {
            self.lastCardCenter = card.center;
            self.lastCardTransform = card.transform;
        }
    }
}


#pragma mark - 滑动结束后操作

- (void)cardItemDidClick:(MGTTCardItem *)card {
    if (card.reuseView && self.delegate && [self.delegate respondsToSelector:@selector(cardView:didSelectView:atIndex:)]) {
        [self.delegate cardView:self didSelectView:card.reuseView atIndex:card.index];
    }
}

- (void)cardItemWillBeginMove:(MGTTCardItem *)card {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginMoveItemInCardView:)]) {
        [self.delegate willBeginMoveItemInCardView:self];
    }
}

- (void)cardItemBeginRemove:(MGTTCardItem *)card Direction:(MGTTCardItemRemoveDirection)direction {
    //开启下层视图触摸事件
    [self.disPlayArray removeObject:card];
    [self.removeArray addObject:card];
    MGTTCardItem * item = [self.disPlayArray firstObject];
    item.userInteractionEnabled = YES;
    //更新视图初始原点
    for (int i = 0; i < self.disPlayArray.count; i++) {
        MGTTCardItem * item = [self.disPlayArray objectAtIndex:i];
        NSDictionary *position = self.positionArray[i];
        item.originalTransform = [self transformForValue:position[@"originalTransform"]];
        item.originalCenter = [self pointForValue:position[@"originalCenter"]];
        item.alpha = [position[@"alpha"] floatValue];
    }
}

- (void)cardItemRemoved:(MGTTCardItem *)card Direction:(MGTTCardItemRemoveDirection)direction {
    //将移除的视图添加到最下层
    card.transform = self.lastCardTransform;
    card.center = self.lastCardCenter;
    card.userInteractionEnabled = NO;
    card.alpha = 0;
    [self insertSubview:card belowSubview:[self.disPlayArray lastObject]];
    [self.disPlayArray addObject:card];
    [self.removeArray removeObject:card];
    
    //更新数据
    if (self.delegate) {
        if (_indexMax == 0) {
            return;
        }
        UIView *subView = [self.delegate cardView:self viewForItemAtIndex:self.index reuseView:card.reuseView];
        card.reuseView = subView;
        card.index = self.index;
        self.index++;
    }
}

#pragma mark - 滑动中更改其他卡片位置
-(void)moveCardsX:(CGFloat)xDistance Y:(CGFloat)yDistance
{
    CGFloat distance = sqrt(pow(xDistance,2) + pow(yDistance,2));
    if (fabs(distance) <= kMGTT_Pan_Distance) {
        for (int i = 1; i < self.itemNumbers - kMGTT_CardCacheNumber; i++) {
            MGTTCardItem *card = self.disPlayArray[i];
            MGTTCardItem *preCard = [self.disPlayArray objectAtIndex:i - 1];
            
            card.transform = CGAffineTransformScale(card.originalTransform, 1 + (1 / self.itemScale - 1) * fabs(distance / kMGTT_Pan_Distance) * 0.6, 1 + (1 / self.itemScale - 1) * fabs(distance / kMGTT_Pan_Distance) * 0.6);//0.6为缩减因数，使放大速度始终小于卡片移动速度
            CGPoint center = card.center;
            center.y = card.originalCenter.y - (card.originalCenter.y - preCard.originalCenter.y) * fabs(distance / kMGTT_Pan_Distance) * 0.6;//此处的0.6同上
            card.center = center;
        }
    }
    if (xDistance > 0) {
        //右边
    } else {
        //左边
    }
}

#pragma mark - 滑动结束后复原其他卡片
- (void)moveBackCards {
    //复位除第一张卡片的位置
    [UIView animateWithDuration:kMGTT_Reset_Animation_Time delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        for (int i = 1; i < self.disPlayArray.count; i++) {
            MGTTCardItem * card = self.disPlayArray[i];
            NSDictionary *position = self.positionArray[i];
            card.transform = [self transformForValue:position[@"originalTransform"]];
            card.center = [self pointForValue:position[@"originalCenter"]];
            card.alpha = [position[@"alpha"] floatValue];
        }
    } completion:nil];
}

#pragma mark - 移出后调整其他卡片
- (void)adjustOtherCards {
    [UIView animateWithDuration:kMGTT_Reset_Animation_Time delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        for (int i = 1; i < self.disPlayArray.count; i++) {
            MGTTCardItem * card = self.disPlayArray[i];
            NSDictionary *position = self.positionArray[i - 1];
            card.transform = [self transformForValue:position[@"originalTransform"]];
            card.center = [self pointForValue:position[@"originalCenter"]];
            card.alpha = [position[@"alpha"] floatValue];
        }
    } completion:nil];
}

#pragma mark - Assist Method
- (NSValue *)valueWithCGPointStruct:(CGPoint )point {
    return [NSValue value:&point withObjCType:@encode(CGPoint)];
}

- (NSValue *)valueWithCGAffineTransformStruct:(CGAffineTransform)transform {
    return [NSValue value:&transform withObjCType:@encode(CGAffineTransform)];
}

- (CGPoint)pointForValue:(NSValue *)value {
    CGPoint p;
    [value getValue:&p];
    return p;
}

- (CGAffineTransform)transformForValue:(NSValue *)value {
    CGAffineTransform t;
    [value getValue:&t];
    return t;
}


#pragma mark - Public Method

- (void)setDelegate:(id<MGTTCardViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

- (NSInteger)index {
    if (_index >= _indexMax) {
        _index = 0;
    }
    return _index;
}

- (void)reloadData {
    if (self.delegate) {
        self.index = 0;
        self.indexMax = [self.delegate numberOfItemsInCardView:self];
        
        if (_indexMax == 0) {
            return;
        }
        
        for (NSInteger i = 0; i < self.disPlayArray.count; i++) {
            MGTTCardItem *item = self.disPlayArray[i];
            UIView *subView = [self.delegate cardView:self viewForItemAtIndex:self.index reuseView:item.reuseView];
            item.reuseView = subView;
            item.index = self.index;
            self.index++;
        }
    }
}


@end
