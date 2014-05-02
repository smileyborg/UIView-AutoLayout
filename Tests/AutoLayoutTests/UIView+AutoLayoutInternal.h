//
//  UIView+AutoLayoutInternal.h
//  UIView+AutoLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/UIView-AutoLayout
//

/**
 A category that exposes the internal (private) helper methods of the UIView+AutoLayout category for use by unit tests.
 */
@interface UIView (AutoLayoutInternal)

+ (NSLayoutAttribute)al_attributeForEdge:(ALEdge)edge;
+ (NSLayoutAttribute)al_attributeForAxis:(ALAxis)axis;
+ (NSLayoutAttribute)al_attributeForDimension:(ALDimension)dimension;
+ (NSLayoutAttribute)al_attributeForALAttribute:(NSInteger)ALAttribute;
+ (UILayoutConstraintAxis)al_constraintAxisForAxis:(ALAxis)axis;

- (void)al_addConstraintUsingGlobalPriority:(NSLayoutConstraint *)constraint;
- (UIView *)al_commonSuperviewWithView:(UIView *)peerView;
- (NSLayoutConstraint *)al_alignToView:(UIView *)peerView withOption:(NSLayoutFormatOptions)alignment forAxis:(ALAxis)axis;

@end


/**
 A category that exposes the internal (private) helper methods of the NSArray+AutoLayout category for use by unit tests.
 */
@interface NSArray (AutoLayoutInternal)

- (UIView *)al_commonSuperviewOfViews;
- (BOOL)al_containsMinimumNumberOfViews:(NSUInteger)minimumNumberOfViews;
- (NSArray *)al_copyViewsOnly;

@end
