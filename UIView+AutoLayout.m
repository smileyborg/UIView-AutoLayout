//
//  UIView+AutoLayout.h
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

#pragma mark - Factory & Initializer Methods

+ (id)newAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (id)initForAutoLayout
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

#pragma mark - Auto Layout Convenience Methods

- (NSArray *)autoCenterInSuperview
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisHorizontal]];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisVertical]];
    return [constraints copy];
}

- (NSLayoutConstraint *)autoCenterInSuperviewAlongAxis:(ALAxis)axis
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSAssert(axis != ALAxisBaseline, @"Cannot center view in superview on the baseline axis.");
    NSLayoutAttribute attribute = [UIView attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:attribute multiplier:1.0f constant:0.0f];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toPositionInSuperview:(CGFloat)value
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSLayoutAttribute attribute = [UIView attributeForEdge:edge];
    NSLayoutConstraint *constraint = nil;
    if (edge == ALEdgeLeft || edge == ALEdgeRight) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:value];
    }
    else {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:value];
    }
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)autoPinCenterAxis:(ALAxis)axis toPositionInSuperview:(CGFloat)value
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSLayoutAttribute attribute = [UIView attributeForAxis:axis];
    NSLayoutConstraint *constraint = nil;
    if (axis == ALAxisVertical) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:value];
    }
    else {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:value];
    }
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    if (edge == ALEdgeBottom || edge == ALEdgeRight) {
        inset = -inset;
    }
    return [self autoPinEdge:edge toEdge:edge ofView:superview withSpacing:inset];
}

- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:insets.top]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:insets.left]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-insets.bottom]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeRight multiplier:1.0f constant:-insets.right]];
    return [constraints copy];
}

- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView
{
    return [self autoPinEdge:edge toEdge:toEdge ofView:peerView withSpacing:0.0f];
}

- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withSpacing:(CGFloat)spacing
{
    return [self autoPinEdge:edge toEdge:toEdge ofView:peerView withSpacing:spacing relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withSpacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForEdge:edge];
    NSLayoutAttribute toAttribute = [UIView attributeForEdge:toEdge];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:spacing];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView
{
    return [self autoAlignAxis:axis toSameAxisOfView:peerView withOffset:0.0f];
}

- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:peerView attribute:attribute multiplier:1.0f constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView
{
    return [self autoMatchDimension:dimension toDimension:toDimension ofView:peerView withOffset:0.0f];
}

- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self autoMatchDimension:dimension toDimension:toDimension ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSArray *)autoSetDimensionsToSize:(CGSize)size
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoSetDimension:ALDimensionWidth toSize:size.width]];
    [constraints addObject:[self autoSetDimension:ALDimensionHeight toSize:size.height]];
    return [constraints copy];
}

- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size
{
    return [self autoSetDimension:dimension toSize:size relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation
{
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:size];
    [self addConstraint:constraint];
    return constraint;
}

#pragma mark - Advanced Auto Layout Methods

- (void)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([views count] > 1, @"Can only distribute 2 or more subviews.");
    NSString *direction = nil;
    switch (axis) {
        case ALAxisHorizontal:
        case ALAxisBaseline:
            direction = @"H:";
            break;
        case ALAxisVertical:
            direction = @"V:";
            break;
        default:
            NSAssert(nil, @"Not a valid axis.");
            return;
    }
    
    UIView *previousView = nil;
    NSDictionary *metrics = @{@"spacing":@(spacing)};
    NSString *vfl = nil;
    for (UIView *view in views)
    {
        vfl = nil;
        NSDictionary *views = nil;
        if (previousView)
        {
            vfl = [NSString stringWithFormat:@"%@[previousView(==view)]-spacing-[view]", direction];
            views = NSDictionaryOfVariableBindings(previousView,view);
        }
        else
        {
            vfl = [NSString stringWithFormat:@"%@|-spacing-[view]", direction];
            views = NSDictionaryOfVariableBindings(view);
        }
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:alignment metrics:metrics views:views]];
        previousView = view;
    }
    
    vfl = [NSString stringWithFormat:@"%@[previousView]-spacing-|", direction];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:alignment metrics:metrics views:NSDictionaryOfVariableBindings(previousView)]];
}

#pragma mark - Internal Helper Methods

+ (NSLayoutAttribute)attributeForEdge:(ALEdge)edge
{
    NSLayoutAttribute attribute;
    switch (edge) {
        case ALEdgeTop:
            attribute = NSLayoutAttributeTop;
            break;
        case ALEdgeLeft:
            attribute = NSLayoutAttributeLeft;
            break;
        case ALEdgeBottom:
            attribute = NSLayoutAttributeBottom;
            break;
        case ALEdgeRight:
            attribute = NSLayoutAttributeRight;
            break;
        default:
            NSAssert(nil, @"Not a valid edge.");
            break;
    }
    return attribute;
}

+ (NSLayoutAttribute)attributeForAxis:(ALAxis)axis
{
    NSLayoutAttribute attribute;
    switch (axis) {
        case ALAxisHorizontal:
            attribute = NSLayoutAttributeCenterY;
            break;
        case ALAxisVertical:
            attribute = NSLayoutAttributeCenterX;
            break;
        case ALAxisBaseline:
            attribute = NSLayoutAttributeBaseline;
            break;
        default:
            NSAssert(nil, @"Not a valid axis.");
            break;
    }
    return attribute;
}

+ (NSLayoutAttribute)attributeForDimension:(ALDimension)dimension
{
    NSLayoutAttribute attribute;
    switch (dimension) {
        case ALDimensionWidth:
            attribute = NSLayoutAttributeWidth;
            break;
        case ALDimensionHeight:
            attribute = NSLayoutAttributeHeight;
            break;
        default:
            NSAssert(nil, @"Not a valid dimension.");
            break;
    }
    return attribute;
}

- (UIView *)commonSuperviewWithView:(UIView *)peerView
{
    UIView *commonSuperview = nil;
    UIView *startView = self;
    do {
        if ([peerView isDescendantOfView:startView]) {
            commonSuperview = startView;
        }
        startView = startView.superview;
    } while (startView && !commonSuperview);
    NSAssert(commonSuperview, @"View and peer must have a common superview.\nView: %@\nPeer: %@", self, peerView);
    return commonSuperview;
}

@end
