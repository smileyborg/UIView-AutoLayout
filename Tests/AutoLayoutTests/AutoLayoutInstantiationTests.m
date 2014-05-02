//
//  AutoLayoutInstantiationTests.m
//  UIView+AutoLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "AutoLayoutTestBase.h"

@interface AutoLayoutInstantiationTests : AutoLayoutTestBase

@end

@implementation AutoLayoutInstantiationTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}

/**
 Test the +[newAutoLayoutView] method.
 */
- (void)testNewAutoLayoutView
{
    UIView *view = [UIView newAutoLayoutView];
    XCTAssertNotNil(view, @"+[UIView newAutoLayoutView] should not return nil.");
    XCTAssert([view isKindOfClass:[UIView class]], @"+[UIView newAutoLayoutView] should return an instance of UIView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from +[UIView newAutoLayoutView] should not translate its autoresizing mask into constraints.");
    
    view = [UILabel newAutoLayoutView];
    XCTAssertNotNil(view, @"+[UILabel newAutoLayoutView] should not return nil.");
    XCTAssert([view isKindOfClass:[UILabel class]], @"+[UILabel newAutoLayoutView] should return an instance of UILabel.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from +[UILabel newAutoLayoutView] should not translate its autoresizing mask into constraints.");
    
    view = [UIImageView newAutoLayoutView];
    XCTAssertNotNil(view, @"+[UIImageView newAutoLayoutView] should not return nil.");
    XCTAssert([view isKindOfClass:[UIImageView class]], @"+[UIImageView newAutoLayoutView] should return an instance of UIImageView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from +[UIImageView newAutoLayoutView] should not translate its autoresizing mask into constraints.");
}

/**
 Test the -[initForAutoLayout] method.
 */
- (void)testInitForAutoLayout
{
    UIView *view = [[UIView alloc] initForAutoLayout];
    XCTAssertNotNil(view, @"-[[UIView alloc] initForAutoLayout] should not return nil.");
    XCTAssert([view isKindOfClass:[UIView class]], @"-[[UIView alloc] initForAutoLayout] should return an instance of UIView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from [[UIView alloc] initForAutoLayout] should not translate its autoresizing mask into constraints.");
    
    view = [[UILabel alloc] initForAutoLayout];
    XCTAssertNotNil(view, @"-[[UILabel alloc] initForAutoLayout] should not return nil.");
    XCTAssert([view isKindOfClass:[UILabel class]], @"-[[UILabel alloc] initForAutoLayout] should return an instance of UILabel.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from [[UILabel alloc] initForAutoLayout] should not translate its autoresizing mask into constraints.");
    
    view = [[UIImageView alloc] initForAutoLayout];
    XCTAssertNotNil(view, @"-[[UIImageView alloc] initForAutoLayout] should not return nil.");
    XCTAssert([view isKindOfClass:[UIImageView class]], @"-[[UIImageView alloc] initForAutoLayout] should return an instance of UIImageView.");
    XCTAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"The view returned from [[UIImageView alloc] initForAutoLayout] should not translate its autoresizing mask into constraints.");
}

@end
