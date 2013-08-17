//
//  UIView+AutoLayout.h
//  Copyright (c) 2013 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ALEdge) {
    ALEdgeTop = 0,
    ALEdgeLeft,
    ALEdgeBottom,
    ALEdgeRight
};

typedef NS_ENUM(NSInteger, ALDimension) {
    ALDimensionWidth = 0,
    ALDimensionHeight
};

typedef NS_ENUM(NSInteger, ALAxis) {
    ALAxisX = 0,
    ALAxisY
};

@interface UIView (AutoLayout)

/** Returns a new view that does not convert autoresizing masks into constraints. */
+ (UIView *)newAutoLayoutView;

/*******************************
 AUTO LAYOUT CONVENIENCE METHODS 
 *******************************/

/** Centers the view in its superview. */
- (NSArray *)autoCenterInSuperview;
/** Centers the view along the given axis within its superview. */
- (NSLayoutConstraint *)autoCenterInSuperviewOnAxis:(ALAxis)axis;

/** Pins an edge of the view to a given edge of another view. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView;
/** Pins an edge of the view to a given edge of another view with spacing. */
- (NSLayoutConstraint *)autoPinEdge:(ALEdge)edge toEdge:(ALEdge)toEdge ofView:(UIView *)peerView withSpacing:(CGFloat)spacing;

/** Pins the given edge of this view to the same edge of the superview with an inset. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset;
/** Pins the edges of the view to the edges of its superview with the given edge insets. */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets;

/** Pins a dimension of the view to a given dimension of another view. */
- (NSLayoutConstraint *)autoPinDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView;
/** Pins a dimension of the view to a given dimension of another view with an offset. */
- (NSLayoutConstraint *)autoPinDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Pins an axis of the view to a given axis of another view. */
- (NSLayoutConstraint *)autoPinCenterAxis:(ALAxis)axis toCenterAxis:(ALAxis)toAxis ofView:(UIView *)peerView;
/** Pins an axis of the view to a given axis of another view with an offset. */
- (NSLayoutConstraint *)autoPinCenterAxis:(ALAxis)axis toCenterAxis:(ALAxis)toAxis ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Sets the view to a specific size. If either dimension is zero, no constraint will be applied. */
- (NSArray *)autoConstrainToSize:(CGSize)size;

/** Spaces the views evenly along the selected axis. Will force the views to the same size to make them fit. */
- (void)autoSpaceSubviews:(NSArray *)views onAxis:(ALAxis)axis withSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment;

/****************************
 ADVANCED AUTO LAYOUT METHODS 
 ****************************/

/** Pin an attribute to the same attribute on another view. Both views must be in the same view hierarchy */
- (NSLayoutConstraint *)autoPinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfView:(UIView *)peerView;

@end
