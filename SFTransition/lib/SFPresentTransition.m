//
//  SFPresentTransition.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFPresentTransition.h"
#import "SFTranslationAnimator.h"


@implementation SFPresentTransition
@synthesize animator = _animator;

#pragma mark getter setter
- (SFAnimator *)animator
{
    if (!_animator) {
        
        _animator = [SFTranslationAnimator new];
    }
    return _animator;
}

- (void)setAnimator:(SFAnimator *)animator
{
    _animator = animator;
    _animator.transitionType = SFTransitionTypePresent;
}




#pragma mark public method
+ (instancetype)transitionWithAnimator:(SFAnimator *)animator
{
    SFPresentTransition *transition = [[SFPresentTransition alloc] init];
    transition.animator = animator;
    return transition;
}




#pragma mark UIViewControllerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    
    [self.animator setToViewController:presented];
    self.animator.reverse = NO;
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.animator.reverse = YES;
    return self.animator;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.animator.interacting ? self.animator:nil;
}

@end
