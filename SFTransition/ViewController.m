//
//  ViewController.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "SFNavigateTransition.h"
#import "SFPresentTransition.h"
#import "SFTranslationAnimator.h"

@interface ViewController ()

- (IBAction)presentClicked:(id)sender;
- (IBAction)pushClicked:(id)sender;

@property (strong, nonatomic) SFNavigateTransition *navigateTransition;
@property (strong, nonatomic) SFPresentTransition *presentTransition;

@end

@implementation ViewController

- (SFPresentTransition *)presentTransition
{
    if (!_presentTransition) {
        
        _presentTransition = [SFPresentTransition new];
        SFTranslationAnimator *animator = [[SFTranslationAnimator alloc] init];
//        animator.springDamping = 0.5;
//        animator.animationDuration = 0.8;
        animator.toViewFrame = CGRectOffset([UIScreen mainScreen].bounds, [UIScreen mainScreen].bounds.size.width, 0);
//    animator.interactable = NO;
    animator.fromViewInsets = UIEdgeInsetsMake(50, 50, 50, 50);
        _presentTransition.animator = animator;
    }
    return _presentTransition;
}

- (SFNavigateTransition *)navigateTransition
{
    if (!_navigateTransition) {
        
        _navigateTransition = [SFNavigateTransition new];
//        SFTranslationAnimator *animator = [[SFTranslationAnimator alloc] init];
//        animator.springDamping = 0.5;
//        animator.animationDuration = 0.8;
//        animator.toViewFrame = CGRectOffset([UIScreen mainScreen].bounds, -[UIScreen mainScreen].bounds.size.width, 0);
//        animator.interactable = NO;
//        animator.fromViewInsets = UIEdgeInsetsZero;
//        _navigateTransition.animator = animator;
    }
    return _navigateTransition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"marster";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentClicked:(id)sender {
    
    DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
    detailVC.isPresent = YES;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    navi.transitioningDelegate = self.presentTransition; //set delegate and custom animator must before presentViewController
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)pushClicked:(id)sender {
    
    DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
    self.navigationController.delegate = self.navigateTransition; //must set delegate before pushViewController
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
