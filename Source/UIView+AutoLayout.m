//
//  UIView+AutoLayout.m
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import "UIView+AutoLayout.h"

#pragma mark - UIView+AutoLayout

@implementation UIView (AutoLayout)

#pragma mark Factory & Initializer Methods

/** 
 Creates and returns a new view that does not convert the autoresizing mask into constraints.
 */
+ (id)newAutoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

/**
 Initializes and returns a new view that does not convert the autoresizing mask into constraints.
 */
- (id)initForAutoLayout
{
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

#pragma mark Auto Layout Convenience Methods

/** 
 A global variable that determines the priority of all constraints created and added by this category.
 Defaults to Required, will only be a different value while executing a constraints block passed into the
 +[UIView autoSetPriority:forConstraints:] method (as that method will reset the value back to Required
 before returning).
 */
static UILayoutPriority _globalConstraintPriority = UILayoutPriorityRequired;

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
    _globalConstraintPriority = priority;
    if (block) {
        block();
    }
    _globalConstraintPriority = UILayoutPriorityRequired;
}

/**
 Removes the given constraint from the view it has been added to.
 
 @param constraint The constraint to remove.
 */
+ (void)removeConstraint:(NSLayoutConstraint *)constraint
{
    if (constraint.secondItem) {
        UIView *commonSuperview = [constraint.firstItem commonSuperviewWithView:constraint.secondItem];
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
    NSLog(nil, @"Failed to remove constraint: %@", constraint);
}

/**
 Removes the given constraints from the views they have been added to.
 
 @param constraints The constraints to remove.
 */
+ (void)removeConstraints:(NSArray *)constraints
{
    for (id object in constraints) {
        if ([object isKindOfClass:[NSLayoutConstraint class]]) {
            [self removeConstraint:((NSLayoutConstraint *)object)];
        } else {
            NSAssert(nil, @"All constraints to remove must be instances of NSLayoutConstraint.");
        }
    }
}

/**
 Removes all explicit constraints that affect the view.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)removeConstraintsAffectingView
{
    [self removeConstraintsAffectingViewIncludingImplicitConstraints:NO];
}

/**
 Removes all constraints that affect the view, optionally including implicit constraints.
 WARNING: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)removeConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
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
    [UIView removeConstraints:constraintsToRemove];
}

/**
 Recursively removes all explicit constraints that affect the view and its subviews.
 NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove.
 */
- (void)removeConstraintsAffectingViewAndSubviews
{
    [self removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:NO];
}

/** 
 Recursively removes all constraints that affect the view and its subviews, optionally including implicit constraints.
 WARNING: Implicit constraints are auto-generated lower priority constraints (such as those that attempt to keep a view at
 its intrinsic content size by hugging its content & resisting compression), and you usually do not want to remove these.
 
 @param shouldRemoveImplicitConstraints Whether implicit constraints should be removed or skipped.
 */
- (void)removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints
{
    [self removeConstraintsAffectingViewIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    for (UIView *subview in self.subviews) {
        [subview removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:shouldRemoveImplicitConstraints];
    }
}

/**
 Centers the view in its superview.
 
 @return An array of constraints added.
 */
- (NSArray *)autoCenterInSuperview
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisHorizontal]];
    [constraints addObject:[self autoCenterInSuperviewAlongAxis:ALAxisVertical]];
    return constraints;
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
    [superview addConstraintUsingGlobalPriority:constraint];
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
    [superview addConstraintUsingGlobalPriority:constraint];
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
    ALEdge superviewEdge;
    switch (edge) {
        case ALEdgeLeft:
        case ALEdgeRight:
            superviewEdge = ALEdgeLeft;
            break;
        case ALEdgeTop:
        case ALEdgeBottom:
            superviewEdge = ALEdgeTop;
            break;
        case ALEdgeLeading:
        case ALEdgeTrailing:
            superviewEdge = ALEdgeLeading;
            break;
        default:
            NSAssert(nil, @"Not a valid edge.");
            break;
    }
    return [self autoPinEdge:edge toEdge:superviewEdge ofView:self.superview withOffset:value];
}

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
 
 @param insets The insets for this view's edges from the superview's edges.
 @return An array of constraints added.
 */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets
{
    UIView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:superview withOffset:insets.top]];
    [constraints addObject:[self autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:superview withOffset:insets.left]];
    [constraints addObject:[self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:superview withOffset:-insets.bottom]];
    [constraints addObject:[self autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:superview withOffset:-insets.right]];
    return constraints;
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
    [superview addConstraintUsingGlobalPriority:constraint];
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
    [superview addConstraintUsingGlobalPriority:constraint];
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
    [superview addConstraintUsingGlobalPriority:constraint];
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
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutAttribute toAttribute = [UIView attributeForDimension:toDimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerView attribute:toAttribute multiplier:multiplier constant:0.0f];
    [superview addConstraintUsingGlobalPriority:constraint];
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
    NSLayoutAttribute attribute = [UIView attributeForDimension:dimension];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:size];
    [self addConstraintUsingGlobalPriority:constraint];
    return constraint;
}

#pragma mark Advanced Auto Layout Methods

/**
 Aligns subviews to one another along a given edge.
 
 @param views An array of subviews to align to one another. Must contain at least 2 views.
 @param edge The edge to which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoAlignSubviews:(NSArray *)views toEdge:(ALEdge)edge
{
    NSAssert([views count] > 1, @"Must provide an array of at least 2 subviews.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (UIView *view in views) {
        if (previousView) {
            [constraints addObject:[view autoPinEdge:edge toEdge:edge ofView:previousView]];
        }
        previousView = view;
    }
    return constraints;
}

/**
 Aligns subviews to one another along a given axis.
 
 @param views An array of subviews to align to one another. Must contain at least 2 views.
 @param axis The axis to which to subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoAlignSubviews:(NSArray *)views toAxis:(ALAxis)axis
{
    NSAssert([views count] > 1, @"Must provide an array of at least 2 subviews.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (UIView *view in views) {
        if (previousView) {
            [constraints addObject:[view autoAlignAxis:axis toSameAxisOfView:previousView]];
        }
        previousView = view;
    }
    return constraints;
}

/**
 Matches a given dimension of all the subviews.
 
 @param views An array of subviews to match in one dimension. Must contain at least 2 views.
 @param dimension The dimension to match for all of the subviews.
 @return An array of constraints added.
 */
- (NSArray *)autoMatchSubviews:(NSArray *)views dimension:(ALDimension)dimension
{
    NSAssert([views count] > 1, @"Must provide an array of at least 2 subviews.");
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *previousView = nil;
    for (UIView *view in views) {
        if (previousView) {
            [constraints addObject:[view autoMatchDimension:dimension toDimension:dimension ofView:previousView]];
        }
        previousView = view;
    }
    return constraints;
}

/**
 Sets the given dimension of all the subviews to a given size.
 
 @param views An array of subviews to set one dimension on.
 @param dimension The dimension of each of the subviews to set.
 @param size The size to set the given dimension of each subview to.
 @return An array of constraints added.
 */
- (NSArray *)autoSetSubviews:(NSArray *)views dimension:(ALDimension)dimension toSize:(CGFloat)size
{
    NSAssert([views count] > 0, @"Must provide an array of at least 1 subview.");
    NSMutableArray *constraints = [NSMutableArray new];
    for (UIView *view in views) {
        [constraints addObject:[view autoSetDimension:dimension toSize:size]];
    }
    return constraints;
}

/**
 Distributes the subviews equally along the selected axis.
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
            firstEdge = ALEdgeLeading;
            lastEdge = ALEdgeTrailing;
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
    UIView *previousView = nil;
    for (UIView *view in views) {
        if (previousView) {
            [constraints addObject:[view autoPinEdge:firstEdge toEdge:lastEdge ofView:previousView withOffset:spacing]];
            [constraints addObject:[view autoMatchDimension:matchedDimension toDimension:matchedDimension ofView:previousView]];
            [constraints addObject:[self alignView:view toView:previousView withOption:alignment forAxis:axis]];
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
 Distributes the subviews equally along the selected axis.
 Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them.
 
 @param views An array of subviews to distribute. Must contain at least 2 views.
 @param axis The axis along which to distribute the subviews.
 @param size The fixed size of each subview in the dimension along the given axis.
 @param alignment The way in which the subviews will be aligned.
 @return An array of constraints added.
 */
- (NSArray *)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment
{
    NSAssert([views count] > 1, @"Can only distribute 2 or more subviews.");
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
            NSAssert(nil, @"Not a valid axis.");
            return nil;
    }
    BOOL isRightToLeftLanguage = [NSLocale characterDirectionForLanguage:[[NSBundle mainBundle] preferredLocalizations][0]] == NSLocaleLanguageDirectionRightToLeft;
    BOOL shouldFlipOrder = isRightToLeftLanguage && (axis != ALAxisVertical); // imitate the effect of leading/trailing when distributing horizontally
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSInteger numberOfViews = [views count];
    UIView *previousView = nil;
    for (NSInteger i = 0; i < numberOfViews; i++) {
        UIView *view = shouldFlipOrder ? views[numberOfViews - i - 1] : views[i];
        [constraints addObject:[view autoSetDimension:fixedDimension toSize:size]];
        CGFloat multiplier = (i * 2.0f + 2.0f) / (numberOfViews + 1.0f);
        CGFloat constant = (multiplier - 1.0f) * size / 2.0f;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:multiplier constant:constant];
        [self addConstraintUsingGlobalPriority:constraint];
        [constraints addObject:constraint];
        if (previousView) {
            [constraints addObject:[self alignView:view toView:previousView withOption:alignment forAxis:axis]];
        }
        previousView = view;
    }
    return constraints;
}

#pragma mark Internal Helper Methods

/**
 Adds the given constraint to the view after setting the constraint's priority to the global constraint priority.
 
 This method is the only one that calls the SDK addConstraint: method directly; all other instances in this category
 should use this method to add constraints so that the global priority is correctly set on constraints.
 
 @param constraint The constraint to set the global priority on and then add to this view.
 */
- (void)addConstraintUsingGlobalPriority:(NSLayoutConstraint *)constraint
{
    constraint.priority = _globalConstraintPriority;
    [self addConstraint:constraint];
}

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
        case ALEdgeLeading:
            attribute = NSLayoutAttributeLeading;
            break;
        case ALEdgeTrailing:
            attribute = NSLayoutAttributeTrailing;
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
 @param axis The axis along which the views are distributed, used to validate the alignment option.
 @return The constraint added.
 */
- (NSLayoutConstraint *)alignView:(UIView *)view toView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment forAxis:(ALAxis)axis
{
    NSLayoutConstraint *constraint = nil;
    switch (alignment) {
        case NSLayoutFormatAlignAllCenterX:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllCenterX.");
            constraint = [view autoAlignAxis:ALAxisVertical toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllCenterY:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllCenterY.");
            constraint = [view autoAlignAxis:ALAxisHorizontal toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllBaseline:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBaseline.");
            constraint = [view autoAlignAxis:ALAxisBaseline toSameAxisOfView:peerView];
            break;
        case NSLayoutFormatAlignAllTop:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllTop.");
            constraint = [view autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeft:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeft.");
            constraint = [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:peerView];
            break;
        case NSLayoutFormatAlignAllBottom:
            NSAssert(axis != ALAxisVertical, @"Cannot align views that are distributed vertically with NSLayoutFormatAlignAllBottom.");
            constraint = [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:peerView];
            break;
        case NSLayoutFormatAlignAllRight:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllRight.");
            constraint = [view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:peerView];
            break;
        case NSLayoutFormatAlignAllLeading:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllLeading.");
            constraint = [view autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:peerView];
            break;
        case NSLayoutFormatAlignAllTrailing:
            NSAssert(axis == ALAxisVertical, @"Cannot align views that are distributed horizontally with NSLayoutFormatAlignAllTrailing.");
            constraint = [view autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:peerView];
            break;
        default:
            NSAssert(nil, @"Unsupported alignment option.");
            break;
    }
    return constraint;
}

@end


#pragma mark - NSLayoutConstraint+AutoLayout

@implementation NSLayoutConstraint (AutoLayout)

/**
 Removes the constraint from the view it has been added to.
 */
- (void)remove
{
    [UIView removeConstraint:self];
}

@end
