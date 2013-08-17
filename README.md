UIView+AutoLayout
=================

Originally forked from [jrturton/UIView-Autolayout](https://github.com/jrturton/UIView-Autolayout) by Tyler Fox. Distributed with the MIT License.

Introduction
------------

A carefully-crafted category on `UIView` that provides a simpler semantic interface for the creation of Auto Layout constraints.

The goal is to provide a pleasant API for the vast majority of common use cases. It's not designed for density or brevity ([Apple's VFL](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) is great for that), instead it is designed for clarity and simplicity. Working with Auto Layout is difficult enough as it is, especially when transitioning large codebases. The API takes inspiration from the Auto Layout UI options available in Interface Builder.

API Cheat Sheet
---------------

This is just a handy overview of the primary methods. Check out the header file for the full API and documentation.
*Note: all of the API methods begin with `auto...` for easy autocomplete!*

*	autoCenterInSuperview
	*	alongAxis:
*	autoPinEdge(s)ToSuperviewEdge(s):withInset(s):
*	autoPinEdge:toEdge:ofView:
	*	withSpacing:
*	autoAlignAxis:toSameAxisOfView:
	*	withOffset:
*	autoMatchDimension:toDimension:ofView:
	*	withOffset:
*	autoSetDimension(s)ToSize:
*	autoSpaceSubviews

Example Usage
-------------

**Using UIView+AutoLayout**

	[self.picture autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kVerticalMargin];
	[self.picture autoSetDimensionsToSize:CGSizeMake(80.0f, 40.0f)];
	[self.picture autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
	[self.picture autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalMargin];
	[self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.picture withSpacing:kHorizontalMargin relation:NSLayoutRelationGreaterThanOrEqual];
	[self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalMargin];
	[self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.picture withSpacing:kVerticalMargin];
	[self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalMargin];
	[self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalMargin];
	
**Without UIView+AutoLayout**

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:0.0f
                                                                  constant:kVerticalMargin]];
    [self.picture addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:80.0f]];
    [self.picture addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:40.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:0.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.picture
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:0.0f
                                                                  constant:kHorizontalMargin]];
...and that's not even half of the constraints required...

Limitations
-----------

*	Will need to use `NSLayoutConstraint` directly in some cases for advanced customization of constraints (e.g. priority)
*	UIView+AutoLayout intentionally does not support "Leading" or "Trailing" for simplicity, therefore it is not intended to support UI that will display right-to-left languages