//
//  UIView+AutoLayout.m
//  v2.0.0
//  https://github.com/smileyborg/UIView-AutoLayout
//
//  Copyright (c) 2012 Richard Turton
//  Copyright (c) 2013 Tyler Fox
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "UIView+AutoLayout.h"


#pragma mark - UIView+AutoLayout

@implementation UIView (AutoLayout)


#pragma mark Factory & Initializer Methods

/** 
 Creates and returns a new view that does not convert the autoresizing mask into constraints.
 */
+ (instancetype)newAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

/**
 Initializes and returns a new view that does not convert the autoresizing mask into constraints.
 */
- (instancetype)initForAutoLayout
{
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}


#pragma mark Set Constraint Priority

/** 
 A global variable that determines the priority of all constraints created and added by this category.
 Defaults to Required, will only be a different value while executing a constraints block passed into the
 +[UIView autoSetPriority:forConstraints:] method (as that method will reset the value back to Required
 before returning).
 NOTE: As UIKit is not thread safe, access to this variable is not synchronized (and should only be done
 on the main thread).
 */
static UILayoutPriority _al_globalConstraintPriority = UILayoutPriorityRequired;

/**
 A global variable that is set to YES while the constraints block passed in to the
 +[UIView autoSetPriority:forConstraints:] method is executing.
 NOTE: As UIKit is not thread safe, access to this variable is not synchronized (and should only be done
 on the main thread).
 */
static BOOL _al_isExecutingConstraintsBlock = NO;

/**
 Sets the constraint priority to the given value for all constraints created using the UIView+AutoLayout
 category API within the given constraints block.
 
 NOTE: This method will have no effect (and will NOT set the priority) on constraints created or added 
 using the SDK directly within the block!
 
 @param priority The layout priority to be set on all constraints in the constraints block.
 @param block A block of method calls to the UIView+AutoLayout API that create and add constraints.
 */
+ (void)autoSetPriority:(UILayoutPriority)priority forConstraints:(ALConstraintsBlock)block
{
    NSAssert(block, @"The constraints block cannot be nil.");
    if (block) {
        _al_globalConstraintPriority = priority;
        _al_isExecutingConstraintsBlock = YES;
        block();
        _al_isExecutingConstraintsBlock = NO;
        _al_globalConstraintPriority = UILayoutPriorityRequired;
    }
}


#pragma mark Remove Constraints

/**
 Removes the given constraint from the view it has been added to.
 
 @param constraint The constraint to remove.
 */
+ (void)autoRemoveConstraint:(NSLayoutConstraint *)constraint
{
    if (constraint.secondItem) {
        UIView *commonSuperview = [constraint.firstItem al_commonSuperviewWithView:constraint.secondItem];
        while (commonSuperview) {
            if ([commonSuperview.constraints containsObject:constraint]) {
                [commonSuperview removeConstraint:constraint];
                return;
            }
            commonSuperview = commonSuperview.superview;
        }
    }
    else {
        [constraint.firstItem removeConstraint:constraint];
        return;
    }
    NSAssert(nil, @"Failed to remove constraint: %@", constraint);
}

/**
 Removes the given constraints from the views they have been added to.
 
 @param constraints The constraints to remove.
 */
+ (void)autoRemoveConstraints:(NSArray *)constraints
{
    for (id object in constraints) {
        if ([object isKindOfClass:[NSLayoutConstraint class]]) {
            [self autoRemoveConstraint:((NSLayoutConstraint *)object)];
        } else {
            NSAssert(nil, @"All constraints to remove must be instances of NSLayoutConstraint.");
        }
    }
}

/**
 Removes all explicit constraints that affect the view.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" a view for reuse in a different way with new constraints. Create a new view instead.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)autoRemoveConstraintsAffectingView
{
    [self autoRemoveConstraintsAffectingViewIncludingImplicitConstraints:NO];
}

/**
 Removes all constraints that affect the view, optionally including implicit constraints.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" a view for reuse in a different way with new constraints. Create a new view instead.
 NOTE: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)autoRemoveConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
{
    NSMutableArray *constraintsToRemove = [NSMutableArray new];
    UIView *startView = self;
    do {
        for (NSLayoutConstraint *constraint in startView.constraints) {
            BOOL isImplicitConstraint = [NSStringFromClass([constraint class]) isEqualToString:@"NSContentSizeLayoutConstraint"];
            if (shouldRemoveImplicitConstraints || !isImplicitConstraint) {
                if (constraint.firstItem == self || constraint.secondItem == self) {
                    [constraintsToRemove addObject:constraint];
                }
            }
        }
        startView = startView.superview;
    } while (startView);
    [UIView autoRemoveConstraints:constraintsToRemove];
}

/**
 Recursively removes all explicit constraints that affect the view and its subviews.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" views for reuse in a different way with new constraints. Create a new view instead.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)autoRemoveConstraintsAffectingViewAndSubviews
{
    [self autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:NO];
}

/** 
 Recursively removes all constraints that affect the view and its subviews, optionally including implicit constraints.
 WARNING: Apple's constraint solver is not optimized for large-scale constraint removal; you may encounter major performance issues after using this method.
          It is not recommended to use this method to "reset" views for reuse in a different way with new constraints. Create a new view instead.
 NOTE: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
{
    [self autoRemoveConstraintsAffectingViewIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    for (UIView *subview in self.subviews) {
        [subview autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    }
}


#pragma mark Center in Superview

/**
 Centers the view in its superview.
 
 @return An array of constraints added.
 */
- (NSArray *)autoCenterInSuperview
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoAlignAxisToSuperviewAxis:ALAxisHorizontal]];
    [constraints addObject:[self autoAlignAxisToSuperviewAxis:ALAxisVertical]];
    return constraints;
}

/**
 Aligns the view to the same axis of its superview.
 
 @param axis The axis of this view and of its superview to align.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoAlignAxisToSuperviewAxis:(ALAxis)axis
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSLayoutAttribute attribute = [UIView al_attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:superview attribute:attribute multiplier:1.0f constant:0.0f];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Pin Edges to Superview

/**
 Pins the given edge of the view to the same edge of the superview with an inset.
 
 @param edge The edge of this view and the superview to pin.
 @param inset The amount to inset this view's edge from the superview's edge.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset
{
    return [self autoPinEdgeToSuperviewEdge:edge withInset:inset relation:NSLayoutRelationEqual];
}

/**
 Pins the given edge of the view to the same edge of the superview with an inset as a maximum or minimum.
 
 @param edge The edge of this view and the superview to pin.
 @param inset The amount to inset this view's edge from the superview's edge.
 @param relation Whether the inset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    if (edge == ALEdgeBottom || edge == ALEdgeRight || edge == ALEdgeTrailing) {
        // The bottom, right, and trailing insets (and relations, if an inequality) are inverted to become offsets
        inset = -inset;
        if (relation == NSLayoutRelationLessThanOrEqual) {
            relation = NSLayoutRelationGreaterThanOrEqual;
        } else if (relation == NSLayoutRelationGreaterThanOrEqual) {
            relation = NSLayoutRelationLessThanOrEqual;
        }
    }
    return [self autoPinEdge:edge toEdge:edge ofView:superview withOffset:inset relation:relation];
}

/**
 Pins the edges of the view to the edges of its superview with the given edge insets.
 The insets.left corresponds to a leading edge constraint, and insets.right corresponds to a trailing edge constraint.
 
 @param insets The insets for this view's edges from the superview's edges.
 @return An array of constraints added.
 */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:insets.top]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:insets.left]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:insets.bottom]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:insets.right]];
    return constraints;
}

/**
 Pins 3 of the 4 edges of the view to the edges of its superview with the given edge insets, excluding one edge.
 The insets.left corresponds to a leading edge constraint, and insets.right corresponds to a trailing edge constraint.
 
 @param insets The insets for this view's edges from the superview's edges. The inset corresponding to the excluded edge
               will be ignored.
 @param edge The edge of this view to exclude in pinning to the superview; this method will not apply any constraint to it.
 @return An array of constraints added.
 */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets excludingEdge:(ALEdge)edge
{
    NSMutableArray *constraints = [NSMutableArray new];
    if (edge != ALEdgeTop) {
        [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:insets.top]];
    }
    if (edge != ALEdgeLeading && edge != ALEdgeLeft) {
        [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:insets.left]];
    }
    if (edge != ALEdgeBottom) {
        [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:insets.bottom]];
    }
    if (edge != ALEdgeTrailing && edge != ALEdgeRight) {
        [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:insets.right]];
    }
    return constraints;
}


#pragma mark Pin Edges

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForEdge:edge];
    NSLayoutAttribute toAttribute = [UIView al_attributeForEdge:toEdge];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Align Axes

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForAxis:axis];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:peerView attribute:attribute multiplier:1.0f constant:offset];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Match Dimensions

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView al_attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [constraint autoInstall];
    return constraint;
}

/**
 Matches a dimension of the view to a multiple of a given dimension of another view.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param multiplier The multiple of the peer view's given dimension that this view's given dimension should be.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier
{
    return [self autoMatchDimension:dimension toDimension:toDimension ofView:peerView withMultiplier:multiplier relation:NSLayoutRelationEqual];
}

/**
 Matches a dimension of the view to a multiple of a given dimension of another view as a maximum or minimum.
 
 @param dimension The dimension of this view to pin.
 @param toDimension The dimension of the peer view to pin to.
 @param peerView The peer view to match to. Must be in the same view hierarchy as this view.
 @param multiplier The multiple of the peer view's given dimension that this view's given dimension should be.
 @param relation Whether the multiple should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView al_attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:multiplier constant:0.0f];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Set Dimensions

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
    return constraints;
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForDimension:dimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:size];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Set Content Compression Resistance & Hugging

/**
 Sets the priority of content compression resistance for an axis.
 NOTE: This method must only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:]
 
 @param axis The axis to set the content compression resistance priority for.
 */
- (void)autoSetContentCompressionResistancePriorityForAxis:(ALAxis)axis
{
    NSAssert(_al_isExecutingConstraintsBlock, @"%@ should only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:]", NSStringFromSelector(_cmd));
    if (_al_isExecutingConstraintsBlock) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UILayoutConstraintAxis constraintAxis = [UIView al_constraintAxisForAxis:axis];
        [self setContentCompressionResistancePriority:_al_globalConstraintPriority forAxis:constraintAxis];
    }
}

/**
 Sets the priority of content hugging for an axis.
 NOTE: This method must only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:]
 
 @param axis The axis to set the content hugging priority for.
 */
- (void)autoSetContentHuggingPriorityForAxis:(ALAxis)axis
{
    NSAssert(_al_isExecutingConstraintsBlock, @"%@ should only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:]", NSStringFromSelector(_cmd));
    if (_al_isExecutingConstraintsBlock) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UILayoutConstraintAxis constraintAxis = [UIView al_constraintAxisForAxis:axis];
        [self setContentHuggingPriority:_al_globalConstraintPriority forAxis:constraintAxis];
    }
}


#pragma mark Constrain Any Attributes

/**
 Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view.
 This method can be used to constrain different types of attributes across two views.
 
 @param ALAttribute Any ALEdge, ALAxis, or ALDimension of this view to constrain.
 @param toALAttribute Any ALEdge, ALAxis, or ALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)ALAttribute toAttribute:(NSInteger)toALAttribute ofView:(UIView *)peerView
{
    return [self autoConstrainAttribute:ALAttribute toAttribute:toALAttribute ofView:peerView withOffset:0.0f];
}

/**
 Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with an offset.
 This method can be used to constrain different types of attributes across two views.
 
 @param ALAttribute Any ALEdge, ALAxis, or ALDimension of this view to constrain.
 @param toALAttribute Any ALEdge, ALAxis, or ALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param offset The offset between the attribute of this view and the attribute of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)ALAttribute toAttribute:(NSInteger)toALAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset
{
    return [self autoConstrainAttribute:ALAttribute toAttribute:toALAttribute ofView:peerView withOffset:offset relation:NSLayoutRelationEqual];
}

/**
 Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with an offset as a maximum or minimum.
 This method can be used to constrain different types of attributes across two views.
 
 @param ALAttribute Any ALEdge, ALAxis, or ALDimension of this view to constrain.
 @param toALAttribute Any ALEdge, ALAxis, or ALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param offset The offset between the attribute of this view and the attribute of the peer view.
 @param relation Whether the offset should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)ALAttribute toAttribute:(NSInteger)toALAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForALAttribute:ALAttribute];
    NSLayoutAttribute toAttribute = [UIView al_attributeForALAttribute:toALAttribute];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:1.0f constant:offset];
    [constraint autoInstall];
    return constraint;
}

/**
 Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with a multiplier.
 This method can be used to constrain different types of attributes across two views.
 
 @param ALAttribute Any ALEdge, ALAxis, or ALDimension of this view to constrain.
 @param toALAttribute Any ALEdge, ALAxis, or ALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param multiplier The multiplier between the attribute of this view and the attribute of the peer view.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)ALAttribute toAttribute:(NSInteger)toALAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier
{
    return [self autoConstrainAttribute:ALAttribute toAttribute:toALAttribute ofView:peerView withMultiplier:multiplier relation:NSLayoutRelationEqual];
}

/**
 Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with a multiplier as a maximum or minimum.
 This method can be used to constrain different types of attributes across two views.
 
 @param ALAttribute Any ALEdge, ALAxis, or ALDimension of this view to constrain.
 @param toALAttribute Any ALEdge, ALAxis, or ALDimension of the peer view to constrain to.
 @param peerView The peer view to constrain to. Must be in the same view hierarchy as this view.
 @param multiplier The multiplier between the attribute of this view and the attribute of the peer view.
 @param relation Whether the multiplier should be at least, at most, or exactly equal to the given value.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)ALAttribute toAttribute:(NSInteger)toALAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = [UIView al_attributeForALAttribute:ALAttribute];
    NSLayoutAttribute toAttribute = [UIView al_attributeForALAttribute:toALAttribute];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:multiplier constant:0.0f];
    [constraint autoInstall];
    return constraint;
}


#pragma mark Pin to Layout Guides

/**
 Pins the top edge of the view to the top layout guide of the given view controller with an inset.
 For compatibility with iOS 6 (where layout guides do not exist), this method will simply pin the top edge of
 the view to the top edge of the given view controller's view with an inset.
 
 @param viewController The view controller whose topLayoutGuide should be used to pin to.
 @param inset The amount to inset this view's top edge from the layout guide.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinToTopLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:viewController.view withOffset:inset];
    } else {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0f constant:inset];
        [viewController.view al_addConstraintUsingGlobalPriority:constraint];
        return constraint;
    }
}

/**
 Pins the bottom edge of the view to the bottom layout guide of the given view controller with an inset.
 For compatibility with iOS 6 (where layout guides do not exist), this method will simply pin the bottom edge of
 the view to the bottom edge of the given view controller's view with an inset.
 
 @param viewController The view controller whose bottomLayoutGuide should be used to pin to.
 @param inset The amount to inset this view's bottom edge from the layout guide.
 @return The constraint added.
 */
- (NSLayoutConstraint *)autoPinToBottomLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:viewController.view withOffset:-inset];
    } else {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewController.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0f constant:-inset];
        [viewController.view al_addConstraintUsingGlobalPriority:constraint];
        return constraint;
    }
}


#pragma mark Internal Helper Methods

/**
 Adds the given constraint to this view after setting the constraint's priority to the global constraint priority.
 
 This method is the only one that calls the SDK addConstraint: method directly; all other instances in this category
 should use this method to add constraints so that the global priority is correctly set on constraints.
 
 @param constraint The constraint to set the global priority on and then add to this view.
 */
- (void)al_addConstraintUsingGlobalPriority:(NSLayoutConstraint *)constraint
{
    constraint.priority = _al_globalConstraintPriority;
    [self addConstraint:constraint];
}

/**
 Returns the corresponding NSLayoutAttribute for the given ALEdge.
 
 @return The layout attribute for the given edge.
 */
+ (NSLayoutAttribute)al_attributeForEdge:(ALEdge)edge
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (edge) {
        case ALEdgeLeft:
            attribute = NSLayoutAttributeLeft;
            break;
        case ALEdgeRight:
            attribute = NSLayoutAttributeRight;
            break;
        case ALEdgeTop:
            attribute = NSLayoutAttributeTop;
            break;
        case ALEdgeBottom:
            attribute = NSLayoutAttributeBottom;
            break;
        case ALEdgeLeading:
            attribute = NSLayoutAttributeLeading;
            break;
        case ALEdgeTrailing:
            attribute = NSLayoutAttributeTrailing;
            break;
        default:
            NSAssert(nil, @"Not a valid ALEdge.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given ALAxis.
 
 @return The layout attribute for the given axis.
 */
+ (NSLayoutAttribute)al_attributeForAxis:(ALAxis)axis
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (axis) {
        case ALAxisVertical:
            attribute = NSLayoutAttributeCenterX;
            break;
        case ALAxisHorizontal:
            attribute = NSLayoutAttributeCenterY;
            break;
        case ALAxisBaseline:
            attribute = NSLayoutAttributeBaseline;
            break;
        default:
            NSAssert(nil, @"Not a valid ALAxis.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given ALDimension.
 
 @return The layout attribute for the given dimension.
 */
+ (NSLayoutAttribute)al_attributeForDimension:(ALDimension)dimension
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (dimension) {
        case ALDimensionWidth:
            attribute = NSLayoutAttributeWidth;
            break;
        case ALDimensionHeight:
            attribute = NSLayoutAttributeHeight;
            break;
        default:
            NSAssert(nil, @"Not a valid ALDimension.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding NSLayoutAttribute for the given ALAttribute.
 
 @return The layout attribute for the given ALAttribute.
 */
+ (NSLayoutAttribute)al_attributeForALAttribute:(NSInteger)ALAttribute
{
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    switch (ALAttribute) {
        case ALEdgeLeft:
            attribute = NSLayoutAttributeLeft;
            break;
        case ALEdgeRight:
            attribute = NSLayoutAttributeRight;
            break;
        case ALEdgeTop:
            attribute = NSLayoutAttributeTop;
            break;
        case ALEdgeBottom:
            attribute = NSLayoutAttributeBottom;
            break;
        case ALEdgeLeading:
            attribute = NSLayoutAttributeLeading;
            break;
        case ALEdgeTrailing:
            attribute = NSLayoutAttributeTrailing;
            break;
        case ALDimensionWidth:
            attribute = NSLayoutAttributeWidth;
            break;
        case ALDimensionHeight:
            attribute = NSLayoutAttributeHeight;
            break;
        case ALAxisVertical:
            attribute = NSLayoutAttributeCenterX;
            break;
        case ALAxisHorizontal:
            attribute = NSLayoutAttributeCenterY;
            break;
        case ALAxisBaseline:
            attribute = NSLayoutAttributeBaseline;
            break;
        default:
            NSAssert(nil, @"Not a valid ALAttribute.");
            break;
    }
    return attribute;
}

/**
 Returns the corresponding UILayoutConstraintAxis for the given ALAxis.
 
 @return The constraint axis for the given axis.
 */
+ (UILayoutConstraintAxis)al_constraintAxisForAxis:(ALAxis)axis
{
    UILayoutConstraintAxis constraintAxis;
    switch (axis) {
        case ALAxisVertical:
            constraintAxis = UILayoutConstraintAxisVertical;
            break;
        case ALAxisHorizontal:
        case ALAxisBaseline:
            constraintAxis = UILayoutConstraintAxisHorizontal;
            break;
        default:
            NSAssert(nil, @"Not a valid ALAxis.");
            break;
    }
    return constraintAxis;
}

/**
 Returns the common superview for this view and the given peer view.
 Raises an exception if this view and the peer view do not share a common superview.
 
 @return The common superview for the two views.
 */
- (UIView *)al_commonSuperviewWithView:(UIView *)peerView
{
    UIView *commonSuperview = nil;
    UIView *startView = self;
    do {
        if ([peerView isDescendantOfView:startView]) {
            commonSuperview = startView;
        }
        startView = startView.superview;
    } while (startView && !commonSuperview);
    NSAssert(commonSuperview, @"Can't constrain two views that do not share a common superview. Make sure that both views have been added into the same view hierarchy.");
    return commonSuperview;
}

/**
 Aligns this view to a peer view with an alignment option.
 
 @param peerView The peer view to align to.
 @param alignment The alignment option to apply to the two views.
 @param axis The axis along which the views are distributed, used to validate the alignment option.
 @return The constraint added.
 */
- (NSLayoutConstraint *)al_alignToView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment forAxis:(ALAxis)axis
{
    NSLayoutConstraint *constraint = nil;
    switch (alignment) {
        case NSLayoutFormatAlignAllCenterX:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllCenterX.");
            constraint = [self autoAlignAxis:ALAxisVertical toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllCenterY:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllCenterY.");
            constraint = [self autoAlignAxis:ALAxisHorizontal toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllBaseline:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBaseline.");
            constraint = [self autoAlignAxis:ALAxisBaseline toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllTop:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllTop.");
            constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeft:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeft.");
            constraint = [self autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:peerView];
            break;
        case NSLayoutFormatAlignAllBottom:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBottom.");
            constraint = [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:peerView];
            break;
        case NSLayoutFormatAlignAllRight:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllRight.");
            constraint = [self autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeading:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeading.");
            constraint = [self autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:peerView];
            break;
        case NSLayoutFormatAlignAllTrailing:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllTrailing.");
            constraint = [self autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:peerView];
            break;
        default:
            NSAssert(nil, @"Unsupported alignment option.");
            break;
    }
    return constraint;
}

@end


#pragma mark - NSArray+AutoLayout

@implementation NSArray (AutoLayout)


#pragma mark Constrain Multiple Views

/**
 Aligns views in this array to one another along a given edge.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param edge The edge to which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoAlignViewsToEdge:(ALEdge)edge
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view autoPinEdge:edge toEdge:edge ofView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Aligns views in this array to one another along a given axis.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param axis The axis to which to subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoAlignViewsToAxis:(ALAxis)axis
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view autoAlignAxis:axis toSameAxisOfView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Matches a given dimension of all the views in this array.
 Note: This array must contain at least 2 views, and all views must share a common superview.
 
 @param dimension The dimension to match for all of the subviews.
 @return An array of constraints added.
 */
- (NSArray *)autoMatchViewsDimension:(ALDimension)dimension
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                [constraints addObject:[view autoMatchDimension:dimension toDimension:dimension ofView:previousView]];
            }
            previousView = view;
        }
    }
    return constraints;
}

/**
 Sets the given dimension of all the views in this array to a given size.
 Note: This array must contain at least 1 view.
 
 @param dimension The dimension of each of the subviews to set.
 @param size The size to set the given dimension of each subview to.
 @return An array of constraints added.
 */
- (NSArray *)autoSetViewsDimension:(ALDimension)dimension toSize:(CGFloat)size
{
    NSAssert([self al_containsMinimumNumberOfViews:1], @"This array must contain at least 1 view.");
    NSMutableArray *constraints = [NSMutableArray new];
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [constraints addObject:[view autoSetDimension:dimension toSize:size]];
        }
    }
    return constraints;
}


#pragma mark Distribute Multiple Views

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them,
 including from the first and last views to their superview.
 
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview, before the first subview and after the last subview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment
{
    return [self autoDistributeViewsAlongAxis:axis withFixedSpacing:spacing insetSpacing:YES alignment:alignment];
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them.
 The first and last views can optionally be inset from their superview by the same amount of spacing as between views.
 
 @param axis The axis along which to distribute the subviews.
 @param spacing The fixed amount of spacing between each subview.
 @param shouldSpaceInsets Whether the first and last views should be equally inset from their superview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSpacing:(CGFloat)spacing insetSpacing:(BOOL)shouldSpaceInsets alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views to distribute.");
    ALDimension matchedDimension;
    ALEdge firstEdge, lastEdge;
    switch (axis) {
        case ALAxisHorizontal:
        case ALAxisBaseline:
            matchedDimension = ALDimensionWidth;
            firstEdge = ALEdgeLeading;
            lastEdge = ALEdgeTrailing;
            break;
        case ALAxisVertical:
            matchedDimension = ALDimensionHeight;
            firstEdge = ALEdgeTop;
            lastEdge = ALEdgeBottom;
            break;
        default:
            NSAssert(nil, @"Not a valid ALAxis.");
            return nil;
    }
    CGFloat leadingSpacing = shouldSpaceInsets ? spacing : 0.0;
    CGFloat trailingSpacing = shouldSpaceInsets ? spacing : 0.0;
    
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            if (previousView) {
                // Second, Third, ... View
                [constraints addObject:[view autoPinEdge:firstEdge toEdge:lastEdge ofView:previousView withOffset:spacing]];
                [constraints addObject:[view autoMatchDimension:matchedDimension toDimension:matchedDimension ofView:previousView]];
                [constraints addObject:[view al_alignToView:previousView withOption:alignment forAxis:axis]];
            }
            else {
                // First view
                [constraints addObject:[view autoPinEdgeToSuperviewEdge:firstEdge withInset:leadingSpacing]];
            }
            previousView = view;
        }
    }
    if (previousView) {
        // Last View
        [constraints addObject:[previousView autoPinEdgeToSuperviewEdge:lastEdge withInset:trailingSpacing]];
    }
    return constraints;
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them,
 including from the first and last views to their superview.
 
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment
{
    return [self autoDistributeViewsAlongAxis:axis withFixedSize:size insetSpacing:YES alignment:alignment];
}

/**
 Distributes the views in this array equally along the selected axis in their superview.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them.
 The first and last views can optionally be inset from their superview by the same amount of spacing as between views.
 
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param shouldSpaceInsets Whether the first and last views should be equally inset from their superview.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSize:(CGFloat)size insetSpacing:(BOOL)shouldSpaceInsets alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([self al_containsMinimumNumberOfViews:2], @"This array must contain at least 2 views to distribute.");
    ALDimension fixedDimension;
    NSLayoutAttribute attribute;
    switch (axis) {
        case ALAxisHorizontal:
        case ALAxisBaseline:
            fixedDimension = ALDimensionWidth;
            attribute = NSLayoutAttributeCenterX;
            break;
        case ALAxisVertical:
            fixedDimension = ALDimensionHeight;
            attribute = NSLayoutAttributeCenterY;
            break;
        default:
            NSAssert(nil, @"Not a valid ALAxis.");
            return nil;
    }
    BOOL isRightToLeftLanguage = [NSLocale characterDirectionForLanguage:[[NSBundle mainBundle] preferredLocalizations][0]] == NSLocaleLanguageDirectionRightToLeft;
    BOOL shouldFlipOrder = isRightToLeftLanguage && (axis != ALAxisVertical); // imitate the effect of leading/trailing when distributing horizontally
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSArray *views = [self al_copyViewsOnly];
    NSUInteger numberOfViews = [views count];
    UIView *commonSuperview = [views al_commonSuperviewOfViews];
    UIView *previousView = nil;
    for (NSUInteger i = 0; i < numberOfViews; i++) {
        UIView *view = shouldFlipOrder ? views[numberOfViews - i - 1] : views[i];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [constraints addObject:[view autoSetDimension:fixedDimension toSize:size]];
        CGFloat multiplier, constant;
        if (shouldSpaceInsets) {
            multiplier = (i * 2.0f + 2.0f) / (numberOfViews + 1.0f);
            constant = (multiplier - 1.0f) * size / 2.0f;
        } else {
            multiplier = (i * 2.0f) / (numberOfViews - 1.0f);
            constant = (-multiplier + 1.0f) * size / 2.0f;
        }
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:commonSuperview attribute:attribute multiplier:multiplier constant:constant];
        [commonSuperview al_addConstraintUsingGlobalPriority:constraint];
        [constraints addObject:constraint];
        if (previousView) {
            [constraints addObject:[view al_alignToView:previousView withOption:alignment forAxis:axis]];
        }
        previousView = view;
    }
    return constraints;
}

#pragma mark Internal Helper Methods

/**
 Returns the common superview for the views in this array.
 Raises an exception if the views in this array do not share a common superview.
 
 @return The common superview for the views in this array.
 */
- (UIView *)al_commonSuperviewOfViews
{
    UIView *commonSuperview = nil;
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)object;
            if (previousView) {
                commonSuperview = [view al_commonSuperviewWithView:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

/**
 Determines whether this array contains a minimum number of views.
 
 @param minimumNumberOfViews The minimum number of views to check for.
 @return YES if this array contains at least the minimum number of views, NO otherwise.
 */
- (BOOL)al_containsMinimumNumberOfViews:(NSUInteger)minimumNumberOfViews
{
    NSUInteger numberOfViews = 0;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            numberOfViews++;
            if (numberOfViews >= minimumNumberOfViews) {
                return YES;
            }
        }
    }
    return numberOfViews >= minimumNumberOfViews;
}

/**
 Creates a copy of this array containing only the view objects in it.
 
 @return A new array containing only the views that are in this array.
 */
- (NSArray *)al_copyViewsOnly
{
    NSMutableArray *viewsOnlyArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            [viewsOnlyArray addObject:object];
        }
    }
    return viewsOnlyArray;
}

@end


#pragma mark - NSLayoutConstraint+AutoLayout

@implementation NSLayoutConstraint (AutoLayout)

/**
 Adds the constraint to the appropriate view.
 */
- (void)autoInstall
{
    NSAssert(self.firstItem || self.secondItem, @"Can't install a constraint with nil firstItem and secondItem.");
    if (self.firstItem) {
        if (self.secondItem) {
            NSAssert([self.firstItem isKindOfClass:[UIView class]] && [self.secondItem isKindOfClass:[UIView class]], @"Can only automatically install a constraint if both items are views.");
            UIView *commonSuperview = [self.firstItem al_commonSuperviewWithView:self.secondItem];
            [commonSuperview al_addConstraintUsingGlobalPriority:self];
        } else {
            NSAssert([self.firstItem isKindOfClass:[UIView class]], @"Can only automatically install a constraint if the item is a view.");
            [self.firstItem al_addConstraintUsingGlobalPriority:self];
        }
    } else {
        NSAssert([self.secondItem isKindOfClass:[UIView class]], @"Can only automatically install a constraint if the item is a view.");
        [self.secondItem al_addConstraintUsingGlobalPriority:self];
    }
}

/**
 Removes the constraint from the view it has been added to.
 */
- (void)autoRemove
{
    [UIView autoRemoveConstraint:self];
}

@end
