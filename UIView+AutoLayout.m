//
//  UIView+AutoLayout.h
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

#pragma mark - Factory & Initializer Methods

/** 
 Returns a new view that does not convert autoresizing masks into constraints.
 */
+ (id)newAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

/**
 Initializes and returns a new view that does not convert autoresizing masks into constraints.
 */
- (id)initForAutoLayout
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

#pragma mark - Auto Layout Convenience Methods

/**
 Centers the view in its superview.
 
 @return An array of constraints added.
 */
- (NSArray *)autoCenterInSuperview
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisHorizontal]];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisVertical]];
    return [constraints copy];
}

/**
 Centers the view along the given axis (horizontal or vertical) within its superview.
 
 @param axis The axis of this view and of its superview to center on.
 @return The constraint added.
 */
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

/**
 Pins the given center axis of the view to a fixed position (X or Y value, depending on axis) in the superview.
 
 @param axis The center axis of this view to pin.
 @param value The x (if horizontal axis) or y (if vertical axis) absolute position in the superview to pin this view at.
 @return The constraint added.
 */
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

/**
 Pins the given edge of the view to a fixed position (X or Y value, depending on edge) in the superview.
 
 @param edge The edge of this view to pin.
 @param value The x (if left or right edge) or y (if top or bottom edge) absolute position in the superview to pin this view at.
 @return The constraint added.
 */
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

/**
 Pins the given edge of the view to the same edge of the superview with an inset.
 
 @param edge The edge of this view and the superview to pin.
 @param inset The amount to inset this view's edge from the superview's edge.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    if (edge == ALEdgeBottom || edge == ALEdgeRight) {
        inset = -inset;
    }
    return [self autoPinEdge:edge toEdge:edge ofView:superview withOffset:inset];
}

/**
 Pins the edges of the view to the edges of its superview with the given edge insets.
 
 @param insets The insets for this view's edges from the superview's edges.
 @return An array of constraints added.
 */
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

/**
 Pins an edge of the view to a given edge of another view.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView
{
    return [self autoPinEdge:edge toEdge:toEdge ofView:peerView withOffset:0.0f];
}

/**
 Pins an edge of the view to a given edge of another view with an offset.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @param offset The offset between the edge of this view and the edge of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self autoPinEdge:edge toEdge:toEdge ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Pins an edge of the view to a given edge of another view with an offset as a maximum or minimum.
 
 @param edge The edge of this view to pin.
 @param toEdge The edge of the peer view to pin to.
 @param peerView The peer view to pin to. Must be in the same view hierarchy as this view.
 @param offset The offset between the edge of this view and the edge of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForEdge:edge];
    NSLayoutAttribute toAttribute = [UIView attributeForEdge:toEdge];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

/**
 Aligns an axis of the view to the same axis of another view.
 
 @param axis The axis of this view and the peer view to align.
 @param peerView The peer view to align to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView
{
    return [self autoAlignAxis:axis toSameAxisOfView:peerView withOffset:0.0f];
}

/**
 Aligns an axis of the view to the same axis of another view with an offset.
 
 @param axis The axis of this view and the peer view to align.
 @param peerView The peer view to align to. Must be in the same view hierarchy as this view.
 @param offset The offset between the axis of this view and the axis of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:peerView attribute:attribute multiplier:1.0f constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

/**
 Matches a dimension of the view to a given dimension of another view.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView
{
    return [self autoMatchDimension:dimension toDimension:toDimension ofView:peerView withOffset:0.0f];
}

/**
 Matches a dimension of the view to a given dimension of another view with an offset.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param offset The offset between the dimension of this view and the dimension of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self autoMatchDimension:dimension toDimension:toDimension ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Matches a dimension of the view to a given dimension of another view with an offset as a maximum or minimum.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param offset The offset between the dimension of this view and the dimension of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

/**
 Sets the view to a specific size.
 
 @param size The size to set this view's dimensions to.
 @return An array of constraints added.
 */
- (NSArray *)autoSetDimensionsToSize:(CGSize)size
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoSetDimension:ALDimensionWidth toSize:size.width]];
    [constraints addObject:[self autoSetDimension:ALDimensionHeight toSize:size.height]];
    return [constraints copy];
}

/**
 Sets the given dimension of the view to a specific size.
 
 @param dimension The dimension of this view to set.
 @param size The size to set the given dimension to.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size
{
    return [self autoSetDimension:dimension toSize:size relation:NSLayoutRelationEqual];
}

/**
 Sets the given dimension of the view to a specific size as a maximum or minimum.
 
 @param dimension The dimension of this view to set.
 @param size The size to set the given dimension to.
 @param relation Whether the size should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation
{
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:size];
    [self addConstraint:constraint];
    return constraint;
}

#pragma mark - Advanced Auto Layout Methods

/**
 Distributes the given subviews along the selected axis.
 Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them.
 
 @param views An array of subviews to distribute. Must contain at least 2 views.
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withFixedSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([views count] > 1, @"Can only distribute 2 or more subviews.");
    ALDimension matchedDimension;
    ALEdge firstEdge, lastEdge;
    switch (axis) {
        case ALAxisHorizontal:
        case ALAxisBaseline:
            matchedDimension = ALDimensionWidth;
            firstEdge = ALEdgeLeft;
            lastEdge = ALEdgeRight;
            break;
        case ALAxisVertical:
            matchedDimension = ALDimensionHeight;
            firstEdge = ALEdgeTop;
            lastEdge = ALEdgeBottom;
            break;
        default:
            NSAssert(nil, @"Not a valid axis.");
            return nil;
    }

    NSMutableArray *constraints = [NSMutableArray new];
    NSInteger numberOfViews = [views count];
    UIView *previousView = nil;
    for (NSInteger i = 0; i < numberOfViews; i++)
    {
        UIView *view = views[i];
        if (previousView) {
            [constraints addObject:[view autoPinEdge:firstEdge toEdge:lastEdge ofView:previousView withOffset:spacing]];
            [constraints addObject:[view autoMatchDimension:matchedDimension toDimension:matchedDimension ofView:previousView]];
            [constraints addObject:[self alignView:view toView:previousView withOption:alignment]];
        }
        else {
            [constraints addObject:[view autoPinEdgeToSuperviewEdge:firstEdge withInset:spacing]];
        }
        previousView = view;
    }
    [constraints addObject:[previousView autoPinEdgeToSuperviewEdge:lastEdge withInset:spacing]];
    return constraints;
}

/**
 Distributes the given subviews along the selected axis.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them.
 
 @param views An array of subviews to distribute. Must contain at least 2 views.
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param alignment The way in which the subviews will be aligned.
 @param mode Whether extra padding should be added before the first view and after the last view.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment extraPadding:(BOOL)mode
{
    NSAssert([views count] > 1, @"Can only distribute 2 or more subviews.");
    ALDimension fixedDimension;
    NSLayoutAttribute attribute;
    switch (axis) {
        case ALAxisHorizontal:
            fixedDimension = ALDimensionWidth;
            attribute = NSLayoutAttributeCenterX;
            break;
        case ALAxisVertical:
            fixedDimension = ALDimensionHeight;
            attribute = NSLayoutAttributeCenterY;
            break;
        case ALAxisBaseline:
            fixedDimension = ALDimensionWidth;
            attribute = NSLayoutAttributeCenterX;
            break;
        default:
            NSAssert(nil, @"Not a valid axis.");
            return nil;
    }
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSInteger numberOfViews = [views count];
    UIView *previousView = nil;
    for (NSInteger i = 0; i < numberOfViews; i++)
    {
        UIView *view = views[i];
        [constraints addObject:[view autoSetDimension:fixedDimension toSize:size]];
        CGFloat multiplier;
        if (mode) {
            multiplier = (i * 2.0f + 2.0f) / (numberOfViews + 1.0f);
        } else {
            multiplier = (i * 2.0f + 1.0f) / (numberOfViews * 1.0f);
        }
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:multiplier constant:0.0f];
        [self addConstraint:constraint];
        [constraints addObject:constraint];
        if (previousView) {
            [constraints addObject:[self alignView:view toView:previousView withOption:alignment]];
        }
        previousView = view;
    }
    return constraints;
}

#pragma mark - Internal Helper Methods

/**
 Returns the corresponding NSLayoutAttribute for the given ALEdge.
 
 @return The layout attribute for the given edge.
 */
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

/**
 Returns the corresponding NSLayoutAttribute for the given ALAxis.
 
 @return The layout attribute for the given axis.
 */
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

/**
 Returns the corresponding NSLayoutAttribute for the given ALDimension.
 
 @return The layout attribute for the given dimension.
 */
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

/**
 Returns the common superview for this view and the given peer view.
 Raises an exception if this view and the peer view do not share a common superview.
 
 @return The common superview for the two views.
 */
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

/**
 Aligns a view to a peer view with an alignment option.
 
 @param view The view to align.
 @param peerView The peer view to align to.
 @param alignment The alignment option to apply to the two views.
 @return The constraint added.
 */
- (NSLayoutConstraint *)alignView:(UIView *)view toView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment
{
    NSLayoutConstraint *constraint = nil;
    switch (alignment) {
        case NSLayoutFormatAlignAllCenterX:
            constraint = [view autoAlignAxis:ALAxisVertical toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllCenterY:
            constraint = [view autoAlignAxis:ALAxisHorizontal toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllBaseline:
            constraint = [view autoAlignAxis:ALAxisBaseline toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllTop:
            constraint = [view autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeft:
            constraint = [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:peerView];
            break;
        case NSLayoutFormatAlignAllBottom:
            constraint = [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:peerView];
            break;
        case NSLayoutFormatAlignAllRight:
            constraint = [view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:peerView];
            break;
        default:
            NSAssert(nil, @"Unsupported alignment option.");
            break;
    }
    return constraint;
}

@end
