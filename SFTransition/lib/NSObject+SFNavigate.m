//
//  NSObject+SFNavigate.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/30.
//  Copyright (c) 2015年 sofach. All rights reserved.
//
#import <objc/runtime.h>

#import "NSObject+SFNavigate.h"

@interface SFNaivgateAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPush;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) CGRect interactiveBounds;
@property (assign, nonatomic) CGRect navigateViewFrame;

@property (weak, nonatomic) UIViewController *popVC;

@property (assign, nonatomic) BOOL interactionInProgress;
@property (assign, nonatomic) BOOL interactable;

@end


@interface NSObject ()

@property (strong, nonatomic) SFNaivgateAnimator *navigateAnimator;

@end

@implementation NSObject (SFNavigate)

- (SFNaivgateAnimator *)navigateAnimator
{
    return objc_getAssociatedObject(self, @selector(navigateAnimator));
}
- (void)setNavigateAnimator:(SFNaivgateAnimator *)animator
{
    objc_setAssociatedObject(self, @selector(navigateAnimator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SFNaivgateAnimator *)getNavigateAnimator
{
    if (!self.navigateAnimator) {
        self.navigateAnimator = [[SFNaivgateAnimator alloc] init];
    }
    return self.navigateAnimator;
}


#pragma mark public method
- (void)sf_setNavigateViewFrame:(CGRect)frame
{
    [self getNavigateAnimator].navigateViewFrame = frame;
}

- (void)sf_setNavigateInteractiveBounds:(CGRect)bounds
{
    [self getNavigateAnimator].interactiveBounds = bounds;
}

- (void)sf_setNavigateInsets:(UIEdgeInsets)insets
{
    [self getNavigateAnimator].insets = insets;
}

- (void)sf_setNavigateInteractable:(BOOL)interactable
{
    [self getNavigateAnimator].interactable = interactable;
}

- (void)sf_setNavigateAnimationDuration:(NSTimeInterval)duration
{
    [self getNavigateAnimator].animationDuration = duration;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    SFNaivgateAnimator *animator = [self getNavigateAnimator];
    
    return animator.interactionInProgress?animator:nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    SFNaivgateAnimator *animator = [self getNavigateAnimator];
    animator.popVC = toVC;
    animator.isPush = operation == UINavigationControllerOperationPush;
    return animator;
}

@end




@interface SFNaivgateAnimator ()

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) BOOL shouldCompleteTransition;

@property (strong, nonatomic) UIView *snapshotView;

@end

@implementation SFNaivgateAnimator

- (id)init
{
    self = [super init];
    if (self) {
        _isPush = YES;
        _interactable = YES;
        _animationDuration = 0.4;
        _insets = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.height/20, [UIScreen mainScreen].bounds.size.width/20, 0, 0);
        _interactiveBounds = [UIScreen mainScreen].bounds;
        _navigateViewFrame = CGRectOffset([UIScreen mainScreen].bounds, [UIScreen mainScreen].bounds.size.width, 0);
    }
    return self;
}

- (void)setPopVC:(UIViewController *)popVC
{
    if (_interactable) {
        _popVC = popVC;
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [_popVC.view addGestureRecognizer:gesture];
    }
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    
    CGPoint translation = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            if (CGRectContainsPoint(_interactiveBounds, translation)) {
                self.interactionInProgress = YES;
                self.beginPoint = translation;
                [_popVC.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (self.interactionInProgress) {
                CGFloat ratio = fabs(_navigateViewFrame.origin.x)/(fabs(_navigateViewFrame.origin.x)+fabs(_navigateViewFrame.origin.y));
                CGFloat directionX = _navigateViewFrame.origin.x==0? 0:_navigateViewFrame.origin.x/fabs(_navigateViewFrame.origin.x);
                CGFloat directionY = _navigateViewFrame.origin.y==0? 0: _navigateViewFrame.origin.y/fabs(_navigateViewFrame.origin.y);
                CGFloat x = (translation.x-self.beginPoint.x)*directionX*ratio;
                CGFloat y = (translation.y-self.beginPoint.y)*directionY*(1-ratio);
                
                if (x<0) {
                    x = 0;
                }
                if (y<0) {
                    y = 0;
                }
                CGFloat fraction = sqrtf(x*x+y*y)*1.5 / sqrt(_navigateViewFrame.origin.x*_navigateViewFrame.origin.x+_navigateViewFrame.origin.y*_navigateViewFrame.origin.y);
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
    if (_isPush) {
        return _animationDuration;
    } else {
        return _animationDuration*0.6;
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
    
    if (_isPush) {
        
        //直接使用fromVC.view做缩放太卡，使用一个截图来代替
        _snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        _snapshotView.frame = fromVC.view.frame;
        [fromVC.view removeFromSuperview];
        [containerView insertSubview:_snapshotView belowSubview:toVC.view];
        
        toVC.view.frame = _navigateViewFrame;
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
        toVC.view.frame = _navigateViewFrame;
        [containerView insertSubview:_snapshotView belowSubview:fromVC.view];
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromVC.view.frame = _navigateViewFrame;
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
