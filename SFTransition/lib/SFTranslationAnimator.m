//
//  SFTranslationAnimator.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/31.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFTranslationAnimator.h"

@interface SFTranslationAnimator ()

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) BOOL shouldCompleteTransition;

@property (strong, nonatomic) UIView *snapshotView;

@property (weak, nonatomic) UIViewController *toViewController;

@end

@implementation SFTranslationAnimator

- (id)init
{
    self = [super init];
    if (self) {
        self.transitionType = SFTransitionTypePresent;
        self.interactable = YES;
        self.animationDuration = 0.5;
        self.interactiveBounds = [UIScreen mainScreen].bounds;

        _springDamping = 1.0;
        _fromViewInsets = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.height/20, [UIScreen mainScreen].bounds.size.width/20, 0, 0);
        _toViewFrame = CGRectOffset([UIScreen mainScreen].bounds, 0, [UIScreen mainScreen].bounds.size.height);
    }
    return self;
}

- (void)setToViewController:(UIViewController *)toViewController
{
    _toViewController = toViewController;
    if (self.interactable) {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [_toViewController.view addGestureRecognizer:gesture];
    }
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {

    CGPoint translation = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            if (CGRectContainsPoint(self.interactiveBounds, translation)) {
                
                self.interacting = YES;
                self.beginPoint = translation;
                
                if (self.transitionType == SFTransitionTypeNavigate && self.toViewController.navigationController) {
                    
                    [self.toViewController.navigationController popViewControllerAnimated:YES];
                    
                } else if (self.transitionType == SFTransitionTypePresent){
                    
                    [self.toViewController dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    
                }
            }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (self.interacting) {
                
                CGFloat ratio = fabs(_toViewFrame.origin.x)/(fabs(_toViewFrame.origin.x)+fabs(_toViewFrame.origin.y));
                CGFloat directionX = _toViewFrame.origin.x==0? 0:_toViewFrame.origin.x/fabs(_toViewFrame.origin.x);
                CGFloat directionY = _toViewFrame.origin.y==0? 0: _toViewFrame.origin.y/fabs(_toViewFrame.origin.y);
                CGFloat x = (translation.x-self.beginPoint.x)*directionX*ratio;
                CGFloat y = (translation.y-self.beginPoint.y)*directionY*(1-ratio);
                
                if (x<0) {
                    x = 0;
                }
                if (y<0) {
                    y = 0;
                }
                CGFloat fraction = sqrtf(x*x+y*y)*1.5 / sqrt(_toViewFrame.origin.x*_toViewFrame.origin.x+_toViewFrame.origin.y*_toViewFrame.origin.y);
                fraction = fminf(fmaxf(fraction, 0.0), 1.0);
                self.shouldCompleteTransition = (fraction > 0.25);
                [self updateInteractiveTransition:fraction];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if (self.interacting) {
                self.interacting = NO;
                
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
    if (self.reverse) {
        
        return self.animationDuration*_springDamping*0.6;
        
    } else {
        
        return self.animationDuration;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect insetFrame = CGRectInset(finalFrame, _fromViewInsets.left, _fromViewInsets.top);
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [containerView addSubview:toVC.view];
    
    if (self.reverse) { // pop or dismiss

        toVC.view.frame = insetFrame;
        _snapshotView.frame = toVC.view.frame;
        _snapshotView.alpha = 0.5;
        _snapshotView.frame = insetFrame;
        toVC.view.frame = _toViewFrame;
        [containerView insertSubview:_snapshotView belowSubview:fromVC.view];
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            fromVC.view.frame = _toViewFrame;
            _snapshotView.frame = finalFrame;
            _snapshotView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
            toVC.view.frame = finalFrame;
            [_snapshotView removeFromSuperview];
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
        [containerView sendSubviewToBack:toVC.view];
        
    } else { //push or present
        
        //直接使用fromVC.view做缩放太卡，使用一个截图来代替
        _snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        _snapshotView.frame = fromVC.view.frame;
        [fromVC.view removeFromSuperview];
        [containerView insertSubview:_snapshotView belowSubview:toVC.view];
        
        toVC.view.frame = _toViewFrame;
        
        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:_springDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            toVC.view.frame = finalFrame;
            _snapshotView.alpha = 0.5;
            _snapshotView.frame = insetFrame;
            
        } completion:^(BOOL finished) {
            
            [_snapshotView removeFromSuperview];
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
    }
    
}

@end
