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

typedef NS_ENUM(NSInteger, ALAxis) {
    ALAxisX = 0,
    ALAxisY
};

typedef NS_ENUM(NSInteger, ALDimension) {
    ALDimensionWidth = 0,
    ALDimensionHeight
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

/** Pins the given edge of the view to the same edge of the superview with an inset. */
- (NSLayoutConstraint *)autoPinEdgeToSuperviewEdge:(ALEdge)edge withInset:(CGFloat)inset;
/** Pins the edges of the view to the edges of its superview with the given edge insets. */
- (NSArray *)autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets)insets;

/** Aligns an axis of the view to a given axis of another view. */
- (NSLayoutConstraint *)autoAlignCenterAxis:(ALAxis)axis toCenterAxis:(ALAxis)toAxis ofView:(UIView *)peerView;
/** Aligns an axis of the view to a given axis of another view with an offset. */
- (NSLayoutConstraint *)autoAlignCenterAxis:(ALAxis)axis toCenterAxis:(ALAxis)toAxis ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Matches a dimension of the view to a given dimension of another view. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView;
/** Matches a dimension of the view to a given dimension of another view with an offset. */
- (NSLayoutConstraint *)autoMatchDimension:(ALDimension)dimension toDimension:(ALDimension)toDimension ofView:(UIView *)peerView withOffset:(CGFloat)offset;

/** Sets the view to a specific size. If either dimension is zero, no constraint will be applied. */
- (NSArray *)autoConstrainToSize:(CGSize)size;

/** Spaces the views evenly along the selected axis. Will force the views to the same size to make them fit. */
- (void)autoSpaceSubviews:(NSArray *)views onAxis:(ALAxis)axis withSpacing:(CGFloat)spacing alignment:(NSLayoutFormatOptions)alignment;

/****************************
 ADVANCED AUTO LAYOUT METHODS 
 ****************************/

/** Pins an attribute of the view to the same attribute of another view. */
- (NSLayoutConstraint *)autoPinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfView:(UIView *)peerView;

@end
