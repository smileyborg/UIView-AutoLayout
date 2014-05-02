//
//  AutoLayoutTestBase.h
//  UIView+AutoLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import <XCTest/XCTest.h>
#import "UIView+AutoLayoutInternal.h"

@interface AutoLayoutTestBase : XCTestCase

// An array of viewA, viewB, viewC, and viewD
@property (nonatomic, readonly) NSArray *viewArray;

// The indendentation below represents how the view hierarchy is set up
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *  viewA;
@property (nonatomic, strong) UIView *      viewA_A;
@property (nonatomic, strong) UIView *          viewA_A_A;
@property (nonatomic, strong) UIView *          viewA_A_B;
@property (nonatomic, strong) UIView *      viewA_B;
@property (nonatomic, strong) UIView *          viewA_B_A;
@property (nonatomic, strong) UIView *  viewB;
@property (nonatomic, strong) UIView *      viewB_A;
@property (nonatomic, strong) UIView *  viewC;
@property (nonatomic, strong) UIView *  viewD;

@end
