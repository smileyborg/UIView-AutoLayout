//
//  ALViewController.m
//  Example
//
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "ALViewController.h"

typedef NS_ENUM(NSInteger, ExampleConstraintDemo) {
    ExampleConstraintDemoReset = 0,
    ExampleConstraintDemo1,
    ExampleConstraintDemo2,
    ExampleConstraintDemo3,
    ExampleConstraintDemo4,
    ExampleConstraintDemo5,
    ExampleConstraintDemo6,
    ExampleConstraintDemoCount
};

@interface ALViewController ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UIView *greenView;
@property (nonatomic, strong) UILabel *orangeView;

@property (nonatomic, assign) ExampleConstraintDemo constraintDemo;

@property (nonatomic, assign) BOOL isAnimatingDemo3;
@property (nonatomic, strong) NSLayoutConstraint *demo3BlueBottomInset;
@property (nonatomic, strong) NSLayoutConstraint *demo3BlueRightInset;
@property (nonatomic, strong) NSLayoutConstraint *demo3RedSizeConstraint;
@property (nonatomic, strong) NSLayoutConstraint *demo3GreenPinConstraint;

@end

@implementation ALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    // Start off by resetting and advancing to the first demo
    self.constraintDemo = ExampleConstraintDemoReset;
    [self nextDemo];

    // Change the demo when the screen is tapped
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextDemo)]];
}

- (void)setupViews
{
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.blueView];
    [self.containerView addSubview:self.redView];
    [self.containerView addSubview:self.yellowView];
    [self.containerView addSubview:self.greenView];
    [self.containerView addSubview:self.orangeView];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self setupConstraintsForCurrentDemo];
}

/**
 Demonstrates:
    - Setting a view to a fixed width
    - Matching the widths of subviews
    - Distributing subviews vertically with a fixed height
 */
- (void)setupDemo1
{
    NSArray *subviews = @[self.blueView, self.redView, self.yellowView, self.greenView, self.orangeView];
    
    [self.blueView autoSetDimension:ALDimensionWidth toSize:80.0f];
    [self.containerView autoMatchSubviews:subviews dimension:ALDimensionWidth];
    
    [self.orangeView autoCenterInSuperviewAlongAxis:ALAxisVertical];
    
    [self.containerView autoDistributeSubviews:subviews alongAxis:ALAxisVertical withFixedSize:30.0f alignment:NSLayoutFormatAlignAllCenterX];
}

/**
 Demonstrates:
 - Matching a view's width to its height
 - Matching the heights of subviews
 - Distributing subviews horizontally with fixed spacing
 */
- (void)setupDemo2
{
    NSArray *subviews = @[self.blueView, self.redView, self.yellowView, self.greenView, self.orangeView];

    [self.blueView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.blueView];
    [self.containerView autoMatchSubviews:subviews dimension:ALDimensionHeight];
    
    [self.orangeView autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    
    [self.containerView autoDistributeSubviews:subviews alongAxis:ALAxisHorizontal withFixedSpacing:10.0f alignment:NSLayoutFormatAlignAllCenterY];
}

/**
 Demonstrates:
 - Animation with constraints
 - Setting a priority less than required
 - Complicated interaction of various constraints
 */
- (void)setupDemo3
{
    [self.orangeView autoSetDimensionsToSize:CGSizeZero]; // orange view not used in this demo; this prevents it from taking on its intrinsic content size
    
    [UIView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
        [self.blueView autoSetDimensionsToSize:CGSizeMake(60.0f, 80.0f)];
    }];
    
    [self.blueView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.blueView.superview withOffset:-80.0f relation:NSLayoutRelationLessThanOrEqual];
    
    self.demo3BlueBottomInset = [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:50.0f];
    self.demo3BlueRightInset = [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f];
    
    [self.redView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.blueView];
    self.demo3RedSizeConstraint = [self.redView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.blueView withOffset:-40.0f];
    
    [self.redView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.blueView];
    [self.blueView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.redView withOffset:30.0f];
    
    self.demo3GreenPinConstraint = [self.greenView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.redView];
    [self.greenView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.redView withOffset:-50.0f];
    [self.greenView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.redView];
    [self.greenView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.blueView];
    
    [self.view layoutIfNeeded];
    
    if (self.isAnimatingDemo3 == NO) {
        // Begin animation on next run loop after initial layout has been calculated
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.isAnimatingDemo3 = YES;
            [self animateDemo3Constraints];
        });
    }
}

/**
 Runs 1 cycle of the animation for demo 3.
 
 Notes for animating constraints:
    - If modifying the constant of a constraint, just set the existing constraint's constant to the new value
    - If modifying any other constraint properties, must remove the old constraint and add a new one with the new values
    - Must call layoutIfNeeded at end of animation block
 */
- (void)animateDemo3Constraints
{
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.demo3BlueBottomInset.constant = -10.0f;
                         self.demo3BlueRightInset.constant = -50.0f;
                         self.demo3RedSizeConstraint.constant = 10.0f;
                         [self.demo3GreenPinConstraint remove];
                         self.demo3GreenPinConstraint = [self.greenView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.blueView];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (self.constraintDemo != ExampleConstraintDemo3) {
                             self.isAnimatingDemo3 = NO;
                             return;
                         }
                         [UIView animateWithDuration:1.0
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.demo3BlueBottomInset.constant = -50.0f;
                                              self.demo3BlueRightInset.constant = -10.0f;
                                              self.demo3RedSizeConstraint.constant = -40.0f;
                                              [self.demo3GreenPinConstraint remove];
                                              self.demo3GreenPinConstraint = [self.greenView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.redView];
                                              [self.view layoutIfNeeded];
                                          }
                                          completion:^(BOOL finished) {
                                              if (self.constraintDemo == ExampleConstraintDemo3) {
                                                  // Loop the animation while viewing the same demo
                                                  [self animateDemo3Constraints];
                                              } else {
                                                  self.isAnimatingDemo3 = NO;
                                              }
                                          }];
                     }];
}

/**
 Demonstrates:
 - Achieving a common layout scenario for content (e.g. an image view, title label, and body text)
 - Matching the widths of two views using a multiplier
 - Pinning views to each other and to the superview to maintain padding and insets
 */
- (void)setupDemo4
{
    [self.redView autoSetDimension:ALDimensionHeight toSize:44.0f];
    [self.blueView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.redView];
    
    [self.redView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0f];
    [self.redView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
    
    [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0f];
    [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
    
    [self.blueView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.redView withOffset:10.0f];
    [self.blueView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.redView withMultiplier:3.0f];
    
    [self.orangeView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.blueView withOffset:20.0f];
    [self.orangeView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.redView];
    [self.orangeView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.blueView];
    [self.orangeView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0f];
}

/**
 Demonstrates:
 - Looping over subviews to apply constraints between them
 - Setting a priority less than required for specific constraints
 - Specifying an inequality constraint that competes with the lower priority constraints
        --> the orange view will maintain at least 10 points of spacing to the bottom of its superview (required constraint),
            and this may require reducing its height (breaking the lower priority constraint)
 */
- (void)setupDemo5
{
    [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0f];
    [self.blueView autoSetDimensionsToSize:CGSizeMake(25.0f, 10.0f)];
    [self.blueView autoCenterInSuperviewAlongAxis:ALAxisVertical];
    
    NSArray *subviews = @[self.blueView, self.redView, self.yellowView, self.greenView, self.orangeView];
    
    [self.containerView autoAlignSubviews:subviews toAxis:ALAxisVertical];
    
    UIView *previousView = nil;
    for (UIView *view in subviews) {
        if (previousView) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousView withOffset:10.0f];
            // The orange view will be allowed to change its size if it conflicts with a required constraint
            UILayoutPriority priority = (view == self.orangeView) ? UILayoutPriorityDefaultHigh + 1 : UILayoutPriorityRequired;
            [UIView autoSetPriority:priority forConstraints:^{
                [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:previousView withMultiplier:1.5f];
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:previousView withMultiplier:2.0f];
            }];
        }
        previousView = view;
    }
    
    [self.orangeView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.containerView withOffset:-10.0f relation:NSLayoutRelationLessThanOrEqual];
}

/**
 Demonstrates:
 - Achieving a common layout scenario for content (e.g. an image view, title label, and body text)
 - Matching the widths of two views using a multiplier
 - Pinning views to each other and to the superview to maintain padding and insets
 - Using leading/trailing constraints instead of left/right
 */
- (void)setupDemo6
{
    [self.redView autoSetDimension:ALDimensionHeight toSize:44.0f];
    [self.blueView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.redView];

    [self.redView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20.0f];
    [self.redView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];

    [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20.0f];
    [self.blueView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];

    [self.blueView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.redView withOffset:10.0f];
    [self.blueView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.redView withMultiplier:3.0f];

    [self.orangeView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.blueView withOffset:20.0f];
    [self.orangeView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.redView withOffset:20.0];
    [self.orangeView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.blueView withOffset:-10.0];
    [self.orangeView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0f];
}


#pragma mark Private Helper Methods

/**
 Switches to the next demo in the sequence.
 Removes all constraints, then calls the next demo's setup method.
 */
- (void)setupConstraintsForCurrentDemo
{
    if (self.constraintDemo >= ExampleConstraintDemoCount) {
        // Return to the first demo after the last one
        self.constraintDemo = ExampleConstraintDemo1;
    }
    
    [self.view removeAllConstraintsFromViewAndSubviews];
    [self.containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
    
    switch (self.constraintDemo) {
        case ExampleConstraintDemo1:
            [self setupDemo1];
            break;
        case ExampleConstraintDemo2:
            [self setupDemo2];
            break;
        case ExampleConstraintDemo3:
            [self setupDemo3];
            break;
        case ExampleConstraintDemo4:
            [self setupDemo4];
            break;
        case ExampleConstraintDemo5:
            [self setupDemo5];
            break;
        case ExampleConstraintDemo6:
            [self setupDemo6];
            break;
        default:
            self.constraintDemo = ExampleConstraintDemoReset;
            break;
    }
}

/**
 Advances to the next demo and flags the view for a constraint update.
 */
- (void)nextDemo
{
    self.constraintDemo++;
    [self.view setNeedsUpdateConstraints];
}

#pragma mark Property Accessors

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView newAutoLayoutView];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}

- (UIView *)blueView
{
    if (!_blueView) {
        _blueView = [[UIView alloc] initForAutoLayout];
        _blueView.backgroundColor = [UIColor blueColor];
    }
    return _blueView;
}

- (UIView *)redView
{
    if (!_redView) {
        _redView = [[UIView alloc] initForAutoLayout];
        _redView.backgroundColor = [UIColor redColor];
    }
    return _redView;
}

- (UIView *)yellowView
{
    if (!_yellowView) {
        _yellowView = [[UIView alloc] initForAutoLayout];
        _yellowView.backgroundColor = [UIColor yellowColor];
    }
    return _yellowView;
}

- (UIView *)greenView
{
    if (!_greenView) {
        _greenView = [[UIView alloc] initForAutoLayout];
        _greenView.backgroundColor = [UIColor greenColor];
    }
    return _greenView;
}

- (UILabel *)orangeView
{
    if (!_orangeView) {
        _orangeView = [[UILabel alloc] initForAutoLayout];
        _orangeView.backgroundColor = [UIColor orangeColor];
        _orangeView.numberOfLines = 0;
        _orangeView.font = [UIFont systemFontOfSize:10.0f];
        _orangeView.textColor = [UIColor whiteColor];
        _orangeView.textAlignment = NSTextAlignmentCenter;
        _orangeView.text = NSLocalizedString(@"Lorem ipsum", nil);
    }
    return _orangeView;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
