//
//  UIViewController+SFPresentBounce.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//
#import <objc/runtime.h>

#import "UIViewController+SFPresentBounce.h"

@interface SFPresentBounceAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPresent;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) CGFloat rotation;
@property (assign, nonatomic) CGFloat springDamping;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

@property (strong, nonatomic) UIView *snapshotView;

@end

@implementation SFPresentBounceAnimator

- (id)init
{
    self = [super init];
    if (self) {
        _isPresent = YES;
        _duration = 0.8;
        _springDamping = 1.0;
        _rotation = M_PI_2;
        _edgeInsets = UIEdgeInsetsZero;
    }
    return self;
}


#pragma mark UIViewControllerAnimatedTransitioning
- (CGFloat)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_isPresent) {
        return _duration;
    } else {
        return _duration*_springDamping;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect insetFrame = CGRectInset(finalFrame, _edgeInsets.top, _edgeInsets.left);
    
    CGFloat dx = [UIScreen mainScreen].bounds.size.width;
    CGFloat dy = tanf(_rotation);
    if (fabs(dy)>[UIScreen mainScreen].bounds.size.height) {
        dy = [UIScreen mainScreen].bounds.size.height;
        dx = dy/tanf(_rotation);
    }
    CGRect orignFrame = CGRectOffset(finalFrame, dx, dy);
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [containerView addSubview:toVC.view];

    if (_isPresent) {
        
        _snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        _snapshotView.frame = fromVC.view.frame;
        [fromVC.view removeFromSuperview];
        [containerView insertSubview:_snapshotView belowSubview:toVC.view];
        
        toVC.view.frame = orignFrame;
        
        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:_springDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            toVC.view.frame = finalFrame;
            _snapshotView.alpha = 0.5;
            _snapshotView.frame = insetFrame;
        } completion:^(BOOL finished) {
            [_snapshotView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        
        toVC.view.frame = insetFrame;
        _snapshotView.frame = toVC.view.frame;
        _snapshotView.alpha = 0.5;
        _snapshotView.frame = insetFrame;
        toVC.view.frame = orignFrame;
        [containerView insertSubview:_snapshotView belowSubview:fromVC.view];
        
        [UIView animateWithDuration:duration animations:^{
            fromVC.view.frame = orignFrame;
            _snapshotView.frame = finalFrame;
            _snapshotView.alpha = 1.0;
        } completion:^(BOOL finished) {
            toVC.view.frame = finalFrame;
            [fromVC.view removeFromSuperview];
            [_snapshotView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
        [containerView sendSubviewToBack:toVC.view];
    }
    
}

@end





@interface UIViewController ()

@property (strong, nonatomic) SFPresentBounceAnimator *presentAnimator;

@end

@implementation UIViewController (SFPresent)

- (SFPresentBounceAnimator *)presentAnimator
{
    return objc_getAssociatedObject(self, @selector(presentAnimator));
}
- (void)setPresentAnimator:(SFPresentBounceAnimator *)animator
{
    objc_setAssociatedObject(self, @selector(presentAnimator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SFPresentBounceAnimator *)getPresentAnimator
{
    if (!self.presentAnimator) {
        self.presentAnimator = [[SFPresentBounceAnimator alloc] init];
    }
    return self.presentAnimator;
}

#pragma mark - public method
- (void)sf_setAnimationDuration:(CGFloat)duration
{
    [self getPresentAnimator].duration = duration;
}

- (void)sf_setAnimationSpringDamping:(CGFloat)springDamping
{
    [self getPresentAnimator].springDamping = springDamping;
}

- (void)sf_setAnimationRotation:(CGFloat)rotation
{
    [self getPresentAnimator].rotation = rotation;
}

#pragma mark UIViewControllerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SFPresentBounceAnimator *animator = [self getPresentAnimator];
    animator.isPresent = YES;
    return [self getPresentAnimator];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    SFPresentBounceAnimator *animator = [self getPresentAnimator];
    animator.isPresent = NO;
    return animator;
}

@end

