//
//  NSObject+SFPresent.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (SFPresent) <UIViewControllerTransitioningDelegate>

/**
 *  设置需要present的View的初始位置
 *  默认是底部
 *
 *  @param frame
 */
- (void)sf_setPresentViewFrame:(CGRect)frame;

/**
 *  设置手势返回交互的区域
 *  默认全屏
 *
 *  @param bounds
 */
- (void)sf_setPresentInteractiveBounds:(CGRect)bounds;

/**
 *  设置当前界面present时的最大缩进
 *
 *  @param insets
 */
- (void)sf_setPresentInsets:(UIEdgeInsets)insets;

/**
 *  设置是否允许手势返回
 *  默认YES
 *
 *  @param interactable 
 */
- (void)sf_setPresentInteractable:(BOOL)interactable;

/**
 *  设置present动画的时长
 *
 *  @param duration
 */
- (void)sf_setPresentAnimationDuration:(NSTimeInterval)duration;

/**
 *  设置动画弹跳的衰减
 *
 *  @param springDamping
 */
- (void)sf_setPresentAnimationSpringDamping:(CGFloat)springDamping;

@end
