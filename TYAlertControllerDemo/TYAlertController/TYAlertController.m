//
//  TYAlertController.m
//  TYAlertControllerDemo
//
//  Created by SunYong on 15/9/1.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAlertController.h"

@interface TYAlertController ()

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, assign) TYAlertControllerStyle preferredStyle;

@property (nonatomic, assign) TYAlertTransitionAnimation transitionAnimation;

@property (nonatomic, assign) Class transitionAnimationClass;

@end

@implementation TYAlertController

#pragma mark - init

- (instancetype)init
{
    if (self = [super init]) {
        [self configureController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configureController];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self configureController];
    }
    return self;
}

- (instancetype)initWithAlertView:(UIView *)alertView preferredStyle:(TYAlertControllerStyle)preferredStyle transitionAnimation:(TYAlertTransitionAnimation)transitionAnimation transitionAnimationClass:(Class)transitionAnimationClass
{
    if (self = [self initWithNibName:nil bundle:nil]) {
        _alertView = alertView;
        _preferredStyle = preferredStyle;
        _transitionAnimation = transitionAnimation;
        _transitionAnimationClass = transitionAnimationClass;
    }
    return self;
}

+ (instancetype)alertControllerWithAlertView:(UIView *)alertView preferredStyle:(TYAlertControllerStyle)preferredStyle
{
    return [[self alloc]initWithAlertView:alertView preferredStyle:preferredStyle transitionAnimation:TYAlertTransitionAnimationFade transitionAnimationClass:nil];
}

+ (instancetype)alertControllerWithAlertView:(UIView *)alertView preferredStyle:(TYAlertControllerStyle)preferredStyle transitionAnimation:(TYAlertTransitionAnimation)transitionAnimation
{
    return [[self alloc]initWithAlertView:alertView preferredStyle:preferredStyle transitionAnimation:transitionAnimation transitionAnimationClass:nil];
}

+ (instancetype)alertControllerWithAlertView:(UIView *)alertView preferredStyle:(TYAlertControllerStyle)preferredStyle transitionAnimationClass:(Class)transitionAnimationClass
{
    return [[self alloc]initWithAlertView:alertView preferredStyle:preferredStyle transitionAnimation:TYAlertTransitionAnimationCustom transitionAnimationClass:transitionAnimationClass];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    [self addSingleTapGesture];
    
    [self configureAlertView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)addSingleTapGesture
{
    if (!self.backgoundTapEnable) {
        return;
    }
    // 点击删除
    self.view.userInteractionEnabled = YES;
    //单指单击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    //手指数
    singleTap.numberOfTouchesRequired = 1;
    //点击次数
    singleTap.numberOfTapsRequired = 1;
    //增加事件者响应者，
    [self.view addGestureRecognizer:singleTap];
}

- (void)configureController
{
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    _backgoundTapEnable = YES;
    _alertViewEdging = 15;
}

- (void)configureAlertView
{
    if (_alertView == nil) {
        NSLog(@"%@: alertView is nil",NSStringFromClass([self class]));
        return;
    }
    _alertView.userInteractionEnabled = YES;
    [self.view addSubview:_alertView];
    _alertView.translatesAutoresizingMaskIntoConstraints = NO;
    switch (_preferredStyle) {
        case TYAlertControllerStyleActionSheet:
            [self layoutActionSheetStyleView];
            break;
        case TYAlertControllerStyleAlert:
            [self layoutAlertStyleView];
            break;
        default:
            break;
    }
}

#pragma mark - layout 

- (void)layoutAlertStyleView
{
    // center X
    NSLayoutConstraint *alertViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    // top Y
    NSLayoutConstraint *alertViewTopYConstraint = nil;
    if (_alertViewOriginY > 0) {
        alertViewTopYConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:_alertViewOriginY];
    }else {
        alertViewTopYConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    }
    
    if (!CGSizeEqualToSize(_alertView.frame.size,CGSizeZero)) {
        // height
        [_alertView addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetHeight(_alertView.frame)]];
        // width
        [_alertView addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetWidth(_alertView.frame)]];
    }else {
        BOOL findAlertViewWidthConstraint = NO;
        for (NSLayoutConstraint *constraint in _alertView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                findAlertViewWidthConstraint = YES;
                break;
            }
        }
        
        if (!findAlertViewWidthConstraint) {
            // width
            [_alertView addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetWidth(self.view.frame)-2*_alertViewEdging]];
        }
    }
    
    [self.view addConstraints:@[alertViewCenterXConstraint,alertViewTopYConstraint]];
}

- (void)layoutActionSheetStyleView
{
    // center X
    NSLayoutConstraint *alertViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    // Bottom
    NSLayoutConstraint *alertViewButtomYConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    // left
    NSLayoutConstraint *alertViewLeftConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    // right
    NSLayoutConstraint *alertViewRightConstraint = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    if (CGRectGetHeight(_alertView.frame) > 0) {
        // height
        [_alertView addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetHeight(_alertView.frame)]];
    }
    
    [self.view addConstraints:@[alertViewCenterXConstraint,alertViewButtomYConstraint,alertViewLeftConstraint,alertViewRightConstraint]];
}

#pragma mark - action

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:self.dismissComplete];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end