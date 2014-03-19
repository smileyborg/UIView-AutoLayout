//
//  UIView+AutoLayout.h
//  v1.3.0
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

#import <UIKit/UIKit.h>

#pragma mark ALAttributes

typedef NS_ENUM(NSInteger, ALEdge) {
    ALEdgeLeft = NSLayoutAttributeLeft,             // the left edge of the view
    ALEdgeRight = NSLayoutAttributeRight,           // the right edge of the view
    ALEdgeTop = NSLayoutAttributeTop,               // the top edge of the view
    ALEdgeBottom = NSLayoutAttributeBottom,         // the bottom edge of the view
    ALEdgeLeading = NSLayoutAttributeLeading,       // the leading edge of the view (left edge for left-to-right languages like English, right edge for right-to-left languages like Arabic)
    ALEdgeTrailing = NSLayoutAttributeTrailing      // the trailing edge of the view (right edge for left-to-right languages like English, left edge for right-to-left languages like Arabic)
};

typedef NS_ENUM(NSInteger, ALDimension) {
    ALDimensionWidth = NSLayoutAttributeWidth,      // the width of the view
    ALDimensionHeight = NSLayoutAttributeHeight     // the height of the view
};

typedef NS_ENUM(NSInteger, ALAxis) {
    ALAxisVertical = NSLayoutAttributeCenterX,      // a vertical line through the center of the view
    ALAxisHorizontal = NSLayoutAttributeCenterY,    // a horizontal line through the center of the view
    ALAxisBaseline = NSLayoutAttributeBaseline      // a horizontal line at the text baseline (not applicable to all views)
};

typedef void(^ALConstraintsBlock)(void);    // a block of method calls to the UIView+AutoLayout category API


#pragma mark - UIView+AutoLayout

/**
 A category on UIView that provides a simple yet powerful interface for creating Auto Layout constraints.
 */
@interface UIView (AutoLayout)


#pragma mark Factory & Initializer Methods

/** Creates and returns a new view that does not convert the autoresizing mask into constraints. */
+ (instancetype)newAutoLayoutView;

/** Initializes and returns a new view that does not convert the autoresizing mask into constraints. */
- (instancetype)initForAutoLayout;


#pragma mark Set Constraint Priority

/** Sets the constraint priority to the given value for all constraints created using the UIView+AutoLayout category API within the given constraints block.
    NOTE: This method will have no effect (and will NOT set the priority) on constraints created or added using the SDK directly within the block! */
+ (void)autoSetPriority:(UILayoutPriority)priority forConstraints:(ALConstraintsBlock)block;


#pragma mark Remove Constraints

/** Removes the given constraint from the view it has been added to. */
+ (void)autoRemoveConstraint:(NSLayoutConstraint *)constraint;

/** Removes the given constraints from the views they have been added to. */
+ (void)autoRemoveConstraints:(NSArray *)constraints;

/** Removes all explicit constraints that affect the view.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint changes; you may encounter major performance issues after using this method.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)autoRemoveConstraintsAffectingView;

/** Removes all constraints that affect the view, optionally including implicit constraints.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint changes; you may encounter major performance issues after using this method.
    NOTE: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)autoRemoveConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;

/** Recursively removes all explicit constraints that affect the view and its subviews.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint changes; you may encounter major performance issues after using this method.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)autoRemoveConstraintsAffectingViewAndSubviews;

/** Recursively removes all constraints from the view and its subviews, optionally including implicit constraints.
    WARNING: Apple's constraint solver is not optimized for large-scale constraint changes; you may encounter major performance issues after using this method.
    NOTE: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;


#pragma mark Center in Superview

/** Centers the view in its superview. */
- (NSArray *)autoCenterInSuperview;

/** Aligns the view to the same axis of its superview. */
- (NSLayoutConstraint *)autoAlignAxisToSuperviewAxis:(ALAxis)axis;


#pragma mark Pin Edges to Superview

/** Pins the given edge of the view to the same edge of the superview with an inset. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset;

/** Pins the given edge of the view to the same edge of the superview with an inset as a maximum or minimum. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset relation:(NSLayoutRelation)relation;

/** Pins the edges of the view to the edges of its superview with the given edge insets. */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets;

/** Pins 3 of the 4 edges of the view to the edges of its superview with the given edge insets, excluding one edge. */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets excludingEdge:(ALEdge)edge;


#pragma mark Pin Edges

/** Pins an edge of the view to a given edge of another view. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView;

/** Pins an edge of the view to a given edge of another view with an offset. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Pins an edge of the view to a given edge of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;


#pragma mark Align Axes

/** Aligns an axis of the view to the same axis of another view. */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView;

/** Aligns an axis of the view to the same axis of another view with an offset. */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset;


#pragma mark Match Dimensions

/** Matches a dimension of the view to a given dimension of another view. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView;

/** Matches a dimension of the view to a given dimension of another view with an offset. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Matches a dimension of the view to a given dimension of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;

/** Matches a dimension of the view to a multiple of a given dimension of another view. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier;

/** Matches a dimension of the view to a multiple of a given dimension of another view as a maximum or minimum. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation;


#pragma mark Set Dimensions

/** Sets the view to a specific size. */
- (NSArray *)autoSetDimensionsToSize:(CGSize)size;

/** Sets the given dimension of the view to a specific size. */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size;

/** Sets the given dimension of the view to a specific size as a maximum or minimum. */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation;


#pragma mark Set Content Compression Resistance & Hugging

/** Sets the priority of content compression resistance for an axis.
    NOTE: This method must only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:] */
- (void)autoSetContentCompressionResistancePriorityForAxis:(ALAxis)axis;

/** Sets the priority of content hugging for an axis.
    NOTE: This method must only be called from within the block passed into the method +[UIView autoSetPriority:forConstraints:] */
- (void)autoSetContentHuggingPriorityForAxis:(ALAxis)axis;


#pragma mark Constrain Any Attributes

/** Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view. */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView;

/** Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with an offset. */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;

/** Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with a multiplier. */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier;

/** Constrains an attribute (any ALEdge, ALAxis, or ALDimension) of the view to a given attribute of another view with a multiplier as a maximum or minimum. */
- (NSLayoutConstraint *)autoConstrainAttribute:(NSInteger)attribute toAttribute:(NSInteger)toAttribute ofView:(UIView *)peerView withMultiplier:(CGFloat)multiplier relation:(NSLayoutRelation)relation;


#pragma mark Pin to Layout Guides

/** Pins the top edge of the view to the top layout guide of the given view controller with an inset. */
- (NSLayoutConstraint *)autoPinToTopLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset;

/** Pins the bottom edge of the view to the bottom layout guide of the given view controller with an inset. */
- (NSLayoutConstraint *)autoPinToBottomLayoutGuideOfViewController:(UIViewController *)viewController withInset:(CGFloat)inset;


#pragma mark Deprecated API Methods

/** DEPRECATED as of v1.1, will be removed at some point in the future. Use -[autoAlignAxisToSuperviewAxis:] instead.
 (This method has simply been renamed due to confusion. The replacement method works identically.)
 Centers the view along the given axis (horizontal or vertical) within its superview. */
- (NSLayoutConstraint *)autoCenterInSuperviewAlongAxis:(ALAxis)axis __attribute__((deprecated));

/** DEPRECATED as of v1.1, will be removed at some point in the future. Use -[autoConstrainAttribute:toAttribute:ofView:withOffset:] instead.
 Pins the given center axis of the view to a fixed position (X or Y value, depending on axis) in the superview. */
- (NSLayoutConstraint *)autoPinCenterAxis:(ALAxis)axis toPositionInSuperview:(CGFloat)value __attribute__((deprecated));

/** DEPRECATED as of v1.1, will be removed at some point in the future. Use -[autoPinEdgeToSuperviewEdge:withInset:] instead.
 Pins the given edge of the view to a fixed position (X or Y value, depending on edge) in the superview. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toPositionInSuperview:(CGFloat)value __attribute__((deprecated));

@end


#pragma mark - NSArray+AutoLayout

/**
 A category on NSArray that provides a simple yet powerful interface for applying constraints to groups of views.
 */
@interface NSArray (AutoLayout)


#pragma mark Constrain Multiple Views

/** Aligns views in this array to one another along a given edge. */
- (NSArray *)autoAlignViewsToEdge:(ALEdge)edge;

/** Aligns views in this array to one another along a given axis. */
- (NSArray *)autoAlignViewsToAxis:(ALAxis)axis;

/** Matches a given dimension of all the views in this array. */
- (NSArray *)autoMatchViewsDimension:(ALDimension)dimension;

/** Sets the given dimension of all the views in this array to a given size. */
- (NSArray *)autoSetViewsDimension:(ALDimension)dimension toSize:(CGFloat)size;


#pragma mark Distribute Multiple Views

/** Distributes the views in this array equally along the selected axis in their superview. Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them. */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment;

/** Distributes the views in this array equally along the selected axis in their superview. Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them. */
- (NSArray *)autoDistributeViewsAlongAxis:(ALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment;

@end


#pragma mark - NSLayoutConstraint+AutoLayout

/**
 A category on NSLayoutConstraint that allows constraints to be easily removed.
 */
@interface NSLayoutConstraint (AutoLayout)

/** Removes the constraint from the view it has been added to. */
- (void)autoRemove;

@end
