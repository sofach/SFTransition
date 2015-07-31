//
//  SFPresentTransition.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAnimator;
@interface SFPresentTransition : NSObject <UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) SFAnimator *animator;

+ (instancetype)transitionWithAnimator:(SFAnimator *)animator;

@end
