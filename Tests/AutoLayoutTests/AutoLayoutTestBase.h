//
//  AutoLayoutTestBase.h
//  UIView+AutoLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import <XCTest/XCTest.h>
#import "UIView+AutoLayoutInternal.h"

#define ALAssertFrameEquals(view, x, y, w, h)       XCTAssert(CGRectEqualToRect(view.frame, CGRectMake(x, y, w, h)))
#define ALAssertOriginEquals(view, x, y)            XCTAssert(CGRectGetMinX(view.frame) == x && CGRectGetMinY(view.frame) == y)
#define ALAssertCenterEquals(view, x, y)            XCTAssert(CGRectGetMidX(view.frame) == x && CGRectGetMidY(view.frame) == y)
#define ALAssertMaxEquals(view, x, y)               XCTAssert(CGRectGetMaxX(view.frame) == x && CGRectGetMaxY(view.frame) == y)
#define ALAssertSizeEquals(view, w, h)              XCTAssert(CGRectGetWidth(view.frame) == w && CGRectGetHeight(view.frame) == h)
#define ALAssertOriginXEquals(view, x)              XCTAssert(CGRectGetMinX(view.frame) == x)
#define ALAssertOriginYEquals(view, y)              XCTAssert(CGRectGetMinY(view.frame) == y)
#define ALAssertCenterXEquals(view, x)              XCTAssert(CGRectGetMidX(view.frame) == x)
#define ALAssertCenterYEquals(view, y)              XCTAssert(CGRectGetMidY(view.frame) == y)
#define ALAssertMaxXEquals(view, x)                 XCTAssert(CGRectGetMaxX(view.frame) == x)
#define ALAssertMaxYEquals(view, y)                 XCTAssert(CGRectGetMaxY(view.frame) == y)
#define ALAssertWidthEquals(view, w)                XCTAssert(CGRectGetWidth(view.frame) == w)
#define ALAssertHeightEquals(view, h)               XCTAssert(CGRectGetHeight(view.frame) == h)

static const CGFloat kContainerViewWidth = 1000.0;
static const CGFloat kContainerViewHeight = 1000.0;

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

/** Forces the container view to immediately do a layout pass, which will evaluate the constraints and set the frames for the container view and subviews. */
- (void)evaluateConstraints;

/** Forces the given view to immediately do a layout pass, which will evaluate the constraints and set the frames for the view and any subviews. */
- (void)evaluateConstraintsForView:(UIView *)view;

@end
