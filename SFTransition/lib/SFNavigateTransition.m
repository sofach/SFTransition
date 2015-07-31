//
//  SFNavigateTransition.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFNavigateTransition.h"
#import "SFTranslationAnimator.h"

@implementation SFNavigateTransition
@synthesize animator = _animator;

#pragma mark getter setter
- (SFAnimator *)animator
{
    if (!_animator) {
        
        SFTranslationAnimator *translationAnimator = [SFTranslationAnimator new];
        translationAnimator.transitionType = SFTransitionTypeNavigate;
        translationAnimator.toViewFrame = CGRectOffset([UIScreen mainScreen].bounds, [UIScreen mainScreen].bounds.size.width, 0);
        _animator = translationAnimator;
    }
    return _animator;
}

- (void)setAnimator:(SFAnimator *)animator
{
    _animator = animator;
    _animator.transitionType = SFTransitionTypeNavigate;
}



#pragma mark public method
+ (instancetype)transitionWithAnimator:(SFAnimator *)animator
{
    SFNavigateTransition *transition = [[SFNavigateTransition alloc] init];
    transition.animator = animator;
    return transition;
}




#pragma mark UINavigationControllerDelegate
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.animator.interacting?self.animator:nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    [self.animator setToViewController:toVC];
    self.animator.reverse = operation==UINavigationControllerOperationPop;
    return self.animator;
}


@end