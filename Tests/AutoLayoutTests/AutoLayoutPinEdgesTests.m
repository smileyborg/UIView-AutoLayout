//
//  AutoLayoutPinEdgesTests.m
//  UIView+AutoLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "AutoLayoutTestBase.h"

@interface AutoLayoutPinEdgesTests : AutoLayoutTestBase

@end

@implementation AutoLayoutPinEdgesTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}

- (void)testAutoPinEdgeToSuperviewEdge
{
    [self.viewA autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.viewA autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
    [self evaluateConstraints];
    ALAssertOriginEquals(self.viewA, 5.0, 10.0);
    
    [self.viewA autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.viewA autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-10.0];
    [self evaluateConstraints];
    ALAssertFrameEquals(self.viewA, 5.0, 10.0, kContainerViewWidth - 5.0, kContainerViewHeight);
    
    [self.viewB autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0];
    [self.viewB autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-52.0];
    ALAssertMaxEquals(self.viewB, kContainerViewWidth, kContainerViewHeight - 52.0);
    
    [self.viewB autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:500.0];
    ALAssertOriginXEquals(self.viewB, 500.0);
    
    [self.viewB autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    ALAssertFrameEquals(self.viewB, 500.0, 0.0, kContainerViewWidth, kContainerViewHeight - 52.0);
}

@end
