//
//  ViewController.m
//  SFTransition
//
//  Created by 陈少华 on 15/7/29.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "NSObject+SFNavigate.h"
#import "NSObject+SFPresent.h"

@interface ViewController ()

- (IBAction)presentClicked:(id)sender;
- (IBAction)pushClicked:(id)sender;

@end

@implementation ViewController

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
    navi.transitioningDelegate = self;
    
    [self sf_setPresentAnimationSpringDamping:0.5];
    [self sf_setPresentAnimationDuration:1.0];
    [self sf_setPresentViewFrame:CGRectOffset([UIScreen mainScreen].bounds, 0*[UIScreen mainScreen].bounds.size.width, -[UIScreen mainScreen].bounds.size.height)];
//    [self sf_setPresentInteractable:NO];
//    [self sf_setPresentInsets:UIEdgeInsetsZero];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)pushClicked:(id)sender {
    
    DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
    self.navigationController.delegate = self;
    [self sf_setNavigateViewFrame:CGRectOffset([UIScreen mainScreen].bounds, 0, [UIScreen mainScreen].bounds.size.height)];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
