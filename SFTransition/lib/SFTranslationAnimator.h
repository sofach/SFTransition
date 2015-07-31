//
//  SFTranslationAnimator.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFAnimator.h"

@interface SFTranslationAnimator : SFAnimator

@property (assign, nonatomic) CGFloat springDamping;
@property (assign, nonatomic) UIEdgeInsets fromViewInsets;
@property (assign, nonatomic) CGRect toViewFrame;

@end
