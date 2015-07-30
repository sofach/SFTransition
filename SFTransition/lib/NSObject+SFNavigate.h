//
//  NSObject+SFNavigate.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/30.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (SFNavigate) <UINavigationControllerDelegate>

/**
 *  设置需要push的View的初始位置
 *  默认是底部
 *
 *  @param frame
 */
- (void)sf_setNavigateViewFrame:(CGRect)frame;

/**
 *  设置手势返回交互的区域
 *  默认全屏
 *
 *  @param bounds
 */
- (void)sf_setNavigateInteractiveBounds:(CGRect)bounds;

/**
 *  设置当前界面push时的最大缩进
 *
 *  @param insets
 */
- (void)sf_setNavigateInsets:(UIEdgeInsets)insets;

/**
 *  设置是否允许手势返回
 *  默认YES
 *
 *  @param interactable
 */
- (void)sf_setNavigateInteractable:(BOOL)interactable;

/**
 *  设置present动画的时长
 *
 *  @param duration
 */
- (void)sf_setNavigateAnimationDuration:(NSTimeInterval)duration;

@end
