//
//  AutoLayoutTests.m
//  AutoLayoutTests
//
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import <XCTest/XCTest.h>

@interface AutoLayoutTests : XCTestCase

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) UIView *view3;
@property (nonatomic, strong) UIView *view4;

@end

@implementation AutoLayoutTests

- (void)setUp
{
    [super setUp];
    
    self.containerView = [UIView newAutoLayoutView];
    self.view1 = [UIView newAutoLayoutView];
    self.view2 = [UIView newAutoLayoutView];
    self.view3 = [UIView newAutoLayoutView];
    self.view4 = [UIView newAutoLayoutView];
    
    [self.containerView addSubview:self.view1];
    [self.containerView addSubview:self.view2];
    [self.containerView addSubview:self.view3];
    [self.containerView addSubview:self.view4];
}

- (void)tearDown
{
    [self removeAllConstraintsFromViewAndSubviews:self.containerView];
    
    [super tearDown];
}

- (void)testNewAutoLayoutView
{
    UIView *view = [UIView newAutoLayoutView];
    
    XCTAssertNotNil(view, @"+[UIView newAutoLayoutView] should not return nil.");
    XCTAssert([view isKindOfClass:[UIView class]], @"+[UIView newAutoLayoutView] should return an instance of UIView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from +[UIView newAutoLayoutView] should not translate its autoresizing mask into constraints.");
}

- (void)testInitForAutoLayout
{
    UIView *view = [[UIView alloc] initForAutoLayout];
    
    XCTAssertNotNil(view, @"-[[UIView alloc] initForAutoLayout] should not return nil.");
    XCTAssert([view isKindOfClass:[UIView class]], @"-[[UIView alloc] initForAutoLayout] should return an instance of UIView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from +[UIView newAutoLayoutView] should not translate its autoresizing mask into constraints.");
}

/**
 Test the removeConstraint: method on UIView.
 Test the case where we're removing a constraint that was added to the closest common superview of the two views it
 constrains.
 */
- (void)testRemoveConstraint
{
    [self.view1 autoCenterInSuperview];
    
    NSInteger constraintsCount = [self.view1.superview.constraints count];
    XCTAssert(constraintsCount > 0, @"view1's superview should have constraints added to it.");
    
    [UIView removeConstraint:self.view1.superview.constraints[0]];
    NSInteger newConstraintsCount = [self.view1.superview.constraints count];
    XCTAssert(constraintsCount - newConstraintsCount == 1, @"view1's superview should have one less constraint on it.");
    
    [self.view2 removeFromSuperview];
    [self.view1 addSubview:self.view2];
    
    [self.view2 autoCenterInSuperview];
}

/**
 Test the removeConstraint: method on UIView.
 Test the case where we're removing a constraint that only applies to one view.
 */
- (void)testRemoveConstraintFromSingleView
{
    NSLayoutConstraint *constraint = [self.view1 autoSetDimension:ALDimensionWidth toSize:10.0f];
    
    NSInteger constraintsCount = [self.view1.constraints count];
    XCTAssert(constraintsCount > 0, @"view1 should have a constraint added to it.");
    
    [UIView removeConstraint:constraint];
    NSInteger newConstraintsCount = [self.view1.constraints count];
    XCTAssert(constraintsCount - newConstraintsCount == 1, @"view1 should have one less constraint on it.");
}

/**
 Test the removeConstraint: method on UIView.
 Test the case where we're removing a constraint that was added to a view that is not the closest common superview of
 the two views it constrains.
 */
- (void)testRemoveConstraintFromNotImmediateSuperview
{
    [self.view3 removeFromSuperview];
    [self.view2 removeFromSuperview];
    [self.view1 addSubview:self.view2];
    [self.view2 addSubview:self.view3];
    
    NSLayoutConstraint *constraint = [self.view3 autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.view2 removeConstraint:constraint];
    [self.containerView addConstraint:constraint];
    
    NSInteger constraintsCount = [self.containerView.constraints count];
    XCTAssert(constraintsCount > 0, @"containerView should have a constraint added to it.");
    
    [UIView removeConstraint:constraint];
    NSInteger newConstraintsCount = [self.containerView.constraints count];
    XCTAssert(constraintsCount - newConstraintsCount == 1, @"containerView should have one less constraint on it.");
}

/**
 Test the removeConstraints: method on UIView.
 */
- (void)testRemoveConstraints
{
    NSArray *constraints = [self.containerView autoDistributeSubviews:@[self.view1, self.view2, self.view3, self.view4] alongAxis:ALAxisHorizontal withFixedSize:10.0f alignment:NSLayoutFormatAlignAllCenterY];
    
    NSInteger constraintsCount = [self.containerView.constraints count];
    XCTAssert(constraintsCount > 0, @"containerView should have constraints added to it.");
    
    [UIView removeConstraints:constraints];
    NSInteger newConstraintsCount = [self.containerView.constraints count];
    XCTAssert(newConstraintsCount == 0, @"containerView should have no constraints on it.");
}

/**
 Test the remove method on NSLayoutConstraint.
 */
- (void)testRemove
{
    NSLayoutConstraint *constraint = [self.containerView autoSetDimension:ALDimensionHeight toSize:0.0f];
    
    NSInteger constraintsCount = [self.containerView.constraints count];
    XCTAssert(constraintsCount > 0, @"containerView should have a constraint added to it.");
    
    [constraint remove];
    NSInteger newConstraintsCount = [self.containerView.constraints count];
    XCTAssert(constraintsCount - newConstraintsCount == 1, @"containerView should have one less constraint on it.");
}

/**
 Recursive helper method to remove all constraints from a given view and its subviews.
 */
- (void)removeAllConstraintsFromViewAndSubviews:(UIView *)view
{
    [UIView removeConstraints:view.constraints];
    for (UIView *subview in view.subviews) {
        [self removeAllConstraintsFromViewAndSubviews:subview];
    }
}

@end
