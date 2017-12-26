//
//  MGTTCard.h
//  MGTTCardExample
//
//  Created by Luqiang on 2017/12/20.
//  Copyright © 2017年 libcore. All rights reserved.
//

#ifndef MGTTCard_h
#define MGTTCard_h

#define kMGTT_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMGTT_ScreenHeight [UIScreen mainScreen].bounds.size.height

//展示数量
#define kMGTT_CardCacheNumber 3
//缩放比例
#define kMGTT_CardScale 0.95
//旋转角度
#define kMGTT_CardRotationAngle (M_PI / 12)

//移出极限值，大于直接移出
#define kMGTT_Action_Margin_Left 150
#define kMGTT_Action_Margin_Right 150

//移出速度极限值，大于直接移出
#define kMGTT_Action_Velocity 200

//复位时间
#define kMGTT_Reset_Animation_Time 0.5

//点击飞出时间
#define kMGTT_Click_Animation_Time 0.5

#define kMGTT_Pan_Distance 120



#endif /* MGTTCard_h */
