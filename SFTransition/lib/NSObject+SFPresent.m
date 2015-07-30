//
//  NSObject+SFPresent.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//
#import <objc/runtime.h>

#import "NSObject+SFPresent.h"


@interface SFPresentAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPresent;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) CGFloat springDamping;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) CGRect presentedViewFrame;
@property (assign, nonatomic) CGRect interactiveBounds;

@property (weak, nonatomic) UIViewController *dismissalVC;

@property (assign, nonatomic) BOOL interactionInProgress;
@property (assign, nonatomic) BOOL interactable;

@end


@interface NSObject ()

@property (strong, nonatomic) SFPresentAnimator *animator;

@end

@implementation NSObject (SFPresent)

- (SFPresentAnimator *)animator
{
    return objc_getAssociatedObject(self, @selector(animator));
}
- (void)setAnimator:(SFPresentAnimator *)animator
{
    objc_setAssociatedObject(self, @selector(animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SFPresentAnimator *)getAnimator
{
    if (!self.animator) {
        self.animator = [[SFPresentAnimator alloc] init];
    }
    return self.animator;
}

#pragma mark - public method
- (void)sf_setPresentViewFrame:(CGRect)frame
{
    [self getAnimator].presentedViewFrame = frame;
}

- (void)sf_setPresentInteractable:(BOOL)interactable
{
    [self getAnimator].interactable = interactable;
}

- (void)sf_setPresentInteractiveBounds:(CGRect)bounds
{
    [self getAnimator].interactiveBounds = bounds;
}

- (void)sf_setPresentInsets:(UIEdgeInsets)insets
{
    [self getAnimator].insets = insets;
}

- (void)sf_setPresentAnimationDuration:(NSTimeInterval)duration
{
    [self getAnimator].animationDuration = duration;
}

- (void)sf_setPresentAnimationSpringDamping:(CGFloat)springDamping
{
    [self getAnimator].springDamping = springDamping;
}

#pragma mark UIViewControllerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SFPresentAnimator *animator = [self getAnimator];
    animator.dismissalVC = presented;
    animator.isPresent = YES;
    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    SFPresentAnimator *animator = [self getAnimator];
    animator.isPresent = NO;
    return animator;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    SFPresentAnimator *presentAnimator = [self getAnimator];
    return presentAnimator.interactionInProgress ? presentAnimator:nil;
}

@end







#pragma mark SFPresentAnimator implementation
@interface SFPresentAnimator ()

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) BOOL shouldCompleteTransition;

@property (strong, nonatomic) UIView *snapshotView;

@end

@implementation SFPresentAnimator

- (id)init
{
    self = [super init];
    if (self) {
        _isPresent = YES;
        _interactable = YES;
        _animationDuration = 0.5;
        _springDamping = 1.0;
        _insets = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.height/20, [UIScreen mainScreen].bounds.size.width/20, 0, 0);
        _presentedViewFrame = CGRectOffset([UIScreen mainScreen].bounds, 0, [UIScreen mainScreen].bounds.size.height);
        _interactiveBounds = [UIScreen mainScreen].bounds;
    }
    return self;
}

- (void)setDismissalVC:(UIViewController *)dismissalVC
{
    if (_interactable) {
        _dismissalVC = dismissalVC;
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [_dismissalVC.view addGestureRecognizer:gesture];
    }
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    
    CGPoint translation = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {

        case UIGestureRecognizerStateBegan:

            if (CGRectContainsPoint(_interactiveBounds, translation)) {
                self.interactionInProgress = YES;
                self.beginPoint = translation;
                [_dismissalVC dismissViewControllerAnimated:YES completion:nil];
            }
            break;
            
        case UIGestureRecognizerStateChanged: {

            if (self.interactionInProgress) {
                CGFloat ratio = fabs(_presentedViewFrame.origin.x)/(fabs(_presentedViewFrame.origin.x)+fabs(_presentedViewFrame.origin.y));
                CGFloat directionX = _presentedViewFrame.origin.x==0? 0:_presentedViewFrame.origin.x/fabs(_presentedViewFrame.origin.x);
                CGFloat directionY = _presentedViewFrame.origin.y==0? 0: _presentedViewFrame.origin.y/fabs(_presentedViewFrame.origin.y);
                CGFloat x = (translation.x-self.beginPoint.x)*directionX*ratio;
                CGFloat y = (translation.y-self.beginPoint.y)*directionY*(1-ratio);

                if (x<0) {
                    x = 0;
                }
                if (y<0) {
                    y = 0;
                }
                CGFloat fraction = sqrtf(x*x+y*y)*1.5 / sqrt(_presentedViewFrame.origin.x*_presentedViewFrame.origin.x+_presentedViewFrame.origin.y*_presentedViewFrame.origin.y);
                fraction = fminf(fmaxf(fraction, 0.0), 1.0);
                self.shouldCompleteTransition = (fraction > 0.25);
                [self updateInteractiveTransition:fraction];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if (self.interactionInProgress) {
                self.interactionInProgress = NO;
                
                if (!self.shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
                {
                    [self cancelInteractiveTransition];
                    
                } else {
                    
                    [self finishInteractiveTransition];
                }
            }
            break;
            
        default:
            break;
    }
}

#pragma mark UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_isPresent) {
        return _animationDuration;
    } else {
        return _animationDuration*_springDamping*0.6;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect insetFrame = CGRectInset(finalFrame, _insets.left, _insets.top);
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [containerView addSubview:toVC.view];
    
    if (_isPresent) {
        
        //直接使用fromVC.view做缩放太卡，使用一个截图来代替
        _snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        _snapshotView.frame = fromVC.view.frame;
        [fromVC.view removeFromSuperview];
        [containerView insertSubview:_snapshotView belowSubview:toVC.view];
        
        toVC.view.frame = _presentedViewFrame;
        
        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:_springDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
        toVC.view.frame = _presentedViewFrame;
        [containerView insertSubview:_snapshotView belowSubview:fromVC.view];
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromVC.view.frame = _presentedViewFrame;
            _snapshotView.frame = finalFrame;
            _snapshotView.alpha = 1.0;
        } completion:^(BOOL finished) {

            toVC.view.frame = finalFrame;
            [_snapshotView removeFromSuperview];
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
        [containerView sendSubviewToBack:toVC.view];
    }
    
}
@end
