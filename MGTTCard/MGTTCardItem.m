//
//  MGTTCardItem.m
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import "MGTTCardItem.h"
#import "MGTTMacro.h"



@interface MGTTCardItem ()

//距离中心距离
@property (nonatomic,assign)CGFloat xFromCenter;
@property (nonatomic,assign)CGFloat yFromCenter;

//卡片移出倾斜角度
@property (nonatomic,assign)CGFloat rotationAngel;

@end

@implementation MGTTCardItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //消除锯齿
        self.layer.allowsEdgeAntialiasing = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self  addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - 拖拽事件处理

-(void)panGesture:(UIPanGestureRecognizer *)gesture {
    
    self.xFromCenter = [gesture translationInView:self].x;
    self.yFromCenter = [gesture translationInView:self].y;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.delegate) {
                [self.delegate cardItemWillBeginMove:self];
            }
            CGFloat locationY = [gesture locationInView:self].y;
            if(locationY < self.frame.size.height / 2) {
                //在卡片的上半部分,正方向倾斜
                self.rotationAngel = kMGTT_CardRotationAngle;
            } else {
                //在卡片的下半部分,负方向倾斜
                self.rotationAngel = -kMGTT_CardRotationAngle;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat rotationStrength = MIN(self.xFromCenter / kMGTT_ScreenWidth, 1.0);
            CGFloat tempRotationAngel;
            tempRotationAngel = (CGFloat) self.rotationAngel * rotationStrength;
            
            self.center = CGPointMake(self.originalCenter.x + self.xFromCenter, self.originalCenter.y + self.yFromCenter);
            self.transform = CGAffineTransformMakeRotation(tempRotationAngel);
            
            if(self.delegate)
                [self.delegate moveCardsX:self.xFromCenter Y:self.yFromCenter];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self followUpActionWithDistance:self.xFromCenter andVelocity:[gesture velocityInView:self.superview]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 点击事件处理

-(void)tapGesture:(UITapGestureRecognizer *)gesture {
    //处理点击事件
    if (self.delegate) {
        [self.delegate cardItemDidClick:self];
    }
}

#pragma mark - 拖拽后续事件处理

-(void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity {
    if (distance > 0 && (distance > kMGTT_Action_Margin_Right || velocity.x > kMGTT_Action_Velocity)) {
        [self rightAction:velocity];
    } else if (distance < 0 && (distance < -kMGTT_Action_Margin_Right || velocity.x < -kMGTT_Action_Velocity)) {
        [self leftAction:velocity];
    }else {
        //复位
        [UIView animateWithDuration:kMGTT_Reset_Animation_Time delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.center = self.originalCenter;
            self.transform = CGAffineTransformMakeRotation(0);
        } completion:nil];
        
        if (self.delegate)
            [self.delegate moveBackCards];
    }
}

#pragma mark - 左边移出

-(void)leftAction:(CGPoint)velocity {
    if (self.delegate) {
        [self.delegate adjustOtherCards];
        [self.delegate cardItemBeginRemove:self Direction:MGTTCardItemRemoveDirectionLeft];
    }
    //横向移动距离
    CGFloat distanceX = -self.frame.size.width - self.originalCenter.x;
    //纵向移动距离
    CGFloat distanceY = distanceX * self.yFromCenter / self.xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(distanceX, self.originalCenter.y + distanceY);
    
    //计算时间
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));
    CGFloat displace = sqrtf(pow(distanceX - self.xFromCenter, 2) + pow(distanceY - self.yFromCenter, 2));
    CGFloat duration = fabs(displace / vel);
    if (duration > 0.4) {
        duration = 0.4;
    } else if(duration < 0.1) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation( - self.rotationAngel);
                     } completion:^(BOOL finished) {
                         if (self.delegate)
                             [self.delegate cardItemRemoved:self Direction:MGTTCardItemRemoveDirectionLeft];
                     }];
}

#pragma mark - 右边移出
-(void)rightAction:(CGPoint)velocity {
    if (self.delegate) {
        [self.delegate adjustOtherCards];
        [self.delegate cardItemBeginRemove:self Direction:MGTTCardItemRemoveDirectionRight];
    }
    //横向移动距离
    CGFloat distanceX = kMGTT_ScreenWidth + self.frame.size.width;
    //纵向移动距离
    CGFloat distanceY = distanceX * self.yFromCenter / self.xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(distanceX, self.originalCenter.y + distanceY);
    
    //计算时间
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace = sqrt(pow(distanceX - self.xFromCenter,2) + pow(distanceY - self.yFromCenter,2));//需要动画完成的剩下距离
    CGFloat duration = fabs(displace/vel);//动画时间
    if (duration > 0.4) {
        duration = 0.4;
    } else if(duration < 0.1){
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(self.rotationAngel);
                     } completion:^(BOOL complete) {
                         if (self.delegate)
                             [self.delegate cardItemRemoved:self Direction:MGTTCardItemRemoveDirectionRight];
                     }];
}

#pragma mark - 按钮左边移出

-(void)leftButtonClickAction {
    if (!self.userInteractionEnabled) {
        return;
    }
    CGPoint finishPoint = CGPointMake(-self.frame.size.width * 2 / 3, 2 * kMGTT_Pan_Distance + self.frame.origin.y);
    [UIView animateWithDuration:kMGTT_Click_Animation_Time
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-kMGTT_CardRotationAngle);
                     } completion:^(BOOL finished) {
                         if (self.delegate)
                             [self.delegate cardItemRemoved:self Direction:MGTTCardItemRemoveDirectionLeft];
                     }];
    if (self.delegate)
        [self.delegate adjustOtherCards];
}

#pragma mark - 按钮右边移出
-(void)rightButtonClickAction {
    if (!self.userInteractionEnabled) {
        return;
    }
    CGPoint finishPoint = CGPointMake(kMGTT_ScreenWidth + self.frame.size.width * 2 / 3, 2 * kMGTT_Pan_Distance + self.frame.origin.y);
    
    [UIView animateWithDuration:kMGTT_Click_Animation_Time
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(kMGTT_CardRotationAngle);
                     } completion:^(BOOL finished) {
                         if (self.delegate)
                             [self.delegate cardItemRemoved:self Direction:MGTTCardItemRemoveDirectionRight];
                     }];
    if (self.delegate)
        [self.delegate adjustOtherCards];
}

#pragma mark - Getter And Setter

- (void)setReuseView:(UIView *)reuseView {
    if (_reuseView != reuseView) {
        _reuseView = reuseView;
        reuseView.layer.allowsEdgeAntialiasing = YES;
        [self addSubview:reuseView];
        reuseView.frame = self.bounds;
    }
}

@end
