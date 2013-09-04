//
//  UIView+AutoLayout.h
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ALEdge) {
    ALEdgeTop = 0,      // the top edge of the view
    ALEdgeLeft,         // the left edge of the view
    ALEdgeBottom,       // the bottom edge of the view
    ALEdgeRight,        // the right edge of the view
    ALEdgeLeading,      // the leading edge of the view (left edge for left-to-right languages like English, right edge for right-to-left languages like Arabic)
    ALEdgeTrailing      // the trailing edge of the view (right edge for left-to-right languages like English, left edge for right-to-left languages like Arabic)
};

typedef NS_ENUM(NSInteger, ALAxis) {
    ALAxisHorizontal = 0,   // a horizontal line through the center of the view
    ALAxisVertical,         // a vertical line through the center of the view
    ALAxisBaseline          // a horizontal line at the text baseline (not applicable to all views)
};

typedef NS_ENUM(NSInteger, ALDimension) {
    ALDimensionWidth = 0,   // the width of the view
    ALDimensionHeight       // the height of the view
};

typedef void(^ALConstraintsBlock)(void);    // a block of method calls to the UIView+AutoLayout category API


#pragma mark - UIView+AutoLayout

/**
 A category on UIView that provides a simpler interface for creating Auto Layout constraints.
 */
@interface UIView (AutoLayout)


#pragma mark Factory & Initializer Methods

/** Creates and returns a new view that does not convert the autoresizing mask into constraints. */
+ (id)newAutoLayoutView;

/** Initializes and returns a new view that does not convert the autoresizing mask into constraints. */
- (id)initForAutoLayout;


#pragma mark Auto Layout Convenience Methods

/** Sets the constraint priority to the given value for all constraints created using the UIView+AutoLayout category API within the given constraints block.
    NOTE: This method will have no effect (and will NOT set the priority) on constraints created or added using the SDK directly within the block! */
+ (void)autoSetPriority:(UILayoutPriority)priority forConstraints:(ALConstraintsBlock)block;


/** Removes the given constraint from the view it has been added to. */
+ (void)removeConstraint:(NSLayoutConstraint *)constraint;

/** Removes the given constraints from the views they have been added to. */
+ (void)removeConstraints:(NSArray *)constraints;

/** Removes all explicit constraints that affect the view.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)removeConstraintsAffectingView;

/** Removes all constraints that affect the view, optionally including implicit constraints.
    WARNING: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)removeConstraintsAffectingViewIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;

/** Recursively removes all explicit constraints that affect the view and its subviews.
    NOTE: This method preserves implicit constraints, such as intrinsic content size constraints, which you usually do not want to remove. */
- (void)removeConstraintsAffectingViewAndSubviews;

/** Recursively removes all constraints from the view and its subviews, optionally including implicit constraints.
    WARNING: Implicit constraints are auto-generated lower priority constraints, and you usually do not want to remove these. */
- (void)removeConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints:(BOOL)shouldRemoveImplicitConstraints;


/** Centers the view in its superview. */
- (NSArray *)autoCenterInSuperview;

/** Centers the view along the given axis (horizontal or vertical) within its superview. */
- (NSLayoutConstraint *)autoCenterInSuperviewAlongAxis:(ALAxis)axis;


/** Pins the given center axis of the view to a fixed position (X or Y value, depending on axis) in the superview. */
- (NSLayoutConstraint *)autoPinCenterAxis:(ALAxis)axis toPositionInSuperview:(CGFloat)value;

/** Pins the given edge of the view to a fixed position (X or Y value, depending on edge) in the superview. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toPositionInSuperview:(CGFloat)value;


/** Pins the given edge of the view to the same edge of the superview with an inset. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset;

/** Pins the given edge of the view to the same edge of the superview with an inset as a maximum or minimum. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset relation:(NSLayoutRelation)relation;

/** Pins the edges of the view to the edges of its superview with the given edge insets. */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets;


/** Pins an edge of the view to a given edge of another view. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView;

/** Pins an edge of the view to a given edge of another view with an offset. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Pins an edge of the view to a given edge of another view with an offset as a maximum or minimum. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withOffset:(CGFloat)offset relation:(NSLayoutRelation)relation;


/** Aligns an axis of the view to the same axis of another view. */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView;

/** Aligns an axis of the view to the same axis of another view with an offset. */
- (NSLayoutConstraint *)autoAlignAxis:(ALAxis)axis toSameAxisOfView:(UIView *)peerView withOffset:(CGFloat)offset;


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


/** Sets the view to a specific size. */
- (NSArray *)autoSetDimensionsToSize:(CGSize)size;

/** Sets the given dimension of the view to a specific size. */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size;

/** Sets the given dimension of the view to a specific size as a maximum or minimum. */
- (NSLayoutConstraint *)autoSetDimension:(ALDimension)dimension toSize:(CGFloat)size relation:(NSLayoutRelation)relation;


#pragma mark Advanced Auto Layout Methods

/** Aligns subviews to one another along a given edge. */
- (NSArray *)autoAlignSubviews:(NSArray *)views toEdge:(ALEdge)edge;

/** Aligns subviews to one another along a given axis. */
- (NSArray *)autoAlignSubviews:(NSArray *)views toAxis:(ALAxis)axis;

/** Matches a given dimension of all the subviews. */
- (NSArray *)autoMatchSubviews:(NSArray *)views dimension:(ALDimension)dimension;

/** Sets the given dimension of all the subviews to a given size. */
- (NSArray *)autoSetSubviews:(NSArray *)views dimension:(ALDimension)dimension toSize:(CGFloat)size;


/** Distributes the subviews equally along the selected axis. Views will be the same size (variable) in the dimension along the axis and will have spacing (fixed) between them. */
- (NSArray *)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withFixedSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment;

/** Distributes the subviews equally along the selected axis. Views will be the same size (fixed) in the dimension along the axis and will have spacing (variable) between them. */
- (NSArray *)autoDistributeSubviews:(NSArray *)views alongAxis:(ALAxis)axis withFixedSize:(CGFloat)size alignment:(NSLayoutFormatOptions)alignment;

@end


#pragma mark - NSLayoutConstraint+AutoLayout

/**
 A category on NSLayoutConstraint that allows constraints to be easily removed.
 */
@interface NSLayoutConstraint (AutoLayout)

/** Removes the constraint from the view it has been added to. */
- (void)remove;

@end
