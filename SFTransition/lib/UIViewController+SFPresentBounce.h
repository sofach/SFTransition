//
//  UIViewController+SFPresentBounce.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SFPresent) <UIViewControllerTransitioningDelegate>

- (void)sf_setAnimationDuration:(CGFloat)duration;
- (void)sf_setAnimationSpringDamping:(CGFloat)springDamping;
- (void)sf_setAnimationRotation:(CGFloat)rotation;

@end
