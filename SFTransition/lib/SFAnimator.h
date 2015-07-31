//
//  SFAnimator.h
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SFTransitionTypePresent = 0,
    SFTransitionTypeNavigate
} SFTransitionType;

@interface SFAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL reverse;
@property (assign, nonatomic) BOOL interacting;
@property (assign, nonatomic) BOOL interactable;

@property (assign, nonatomic) SFTransitionType transitionType;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) CGRect interactiveBounds;

- (void)setToViewController:(UIViewController *)toViewController;

@end
