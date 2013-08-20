UIView+AutoLayout
=================

*Originally forked from [jrturton/UIView-Autolayout](https://github.com/jrturton/UIView-Autolayout) by Tyler Fox. Distributed with the MIT License.*

Introduction
------------

A carefully-crafted category on `UIView` (and a one-method category on `NSLayoutConstraint`) that provides a simpler semantic interface for creating Auto Layout constraints.

The goal is to provide a pleasant API for the vast majority of common use cases. It's not designed for density or brevity ([Apple's VFL](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) is great for that), instead it is designed for clarity and simplicity. Working with Auto Layout is difficult enough as it is, especially when transitioning large codebases to support it. The API takes inspiration from the Auto Layout UI options available in Interface Builder.

API Cheat Sheet
---------------

This is just a handy overview of the primary methods. Check out the header file for the full API and documentation.

*Note: all of the API methods begin with `auto...` for easy autocompletion!*

**UIView**

*	\+ removeConstraint(s):
*	\- autoCenterInSuperview(alongAxis:)
*	\- autoPinCenterAxis:toPositionInSuperview:
*	\- autoPinEdge:toPositionInSuperview:
*	\- autoPinEdge(s)ToSuperviewEdge(s):withInset(s):
*	\- autoPinEdge:toEdge:ofView:(withOffset:)
*	\- autoAlignAxis:toSameAxisOfView:(withOffset:)
*	\- autoMatchDimension:toDimension:ofView:(withOffset:)
*	\- autoSetDimension(s)ToSize:
*	\- autoDistributeSubviews:alongAxis:withFixedSpacing:alignment:
*	\- autoDistributeSubviews:alongAxis:withFixedSize:alignment:

**NSLayoutConstraint**

*	\- remove

Setup
-----
*Note: you must be developing for iOS 6.0 or later to use Auto Layout.*

**Manually from GitHub**

1.	Download the `UIView+AutoLayout.h` and `UIView+AutoLayout.m` files and add them to your Xcode project
2.	`#import UIView+AutoLayout.h` wherever you need it

	*(Hint: adding the import to your precompiled header file once will allow you to access the API from anywhere in your app!)*
3.	Start joyfully creating constraints in code!

**Using [CocoaPods](http://cocoapods.org)**

1. Add the pod `UIView+AutoLayout` to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile).

    	platform :ios
    	pod 'UIView+AutoLayout'

2. Run `pod install` from Terminal.
3. Open your app's `.xcworkspace` file to launch Xcode and start joyfully creating constraints in code!

Example Usage
-------------

**Using UIView+AutoLayout**

	[pictureView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kVerticalMargin];
	[pictureView autoSetDimensionsToSize:CGSizeMake(80.0f, 40.0f)];
	[pictureView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:titleLabel];
	[pictureView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalMargin];
	[titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:pictureView withOffset:kHorizontalMargin relation:NSLayoutRelationGreaterThanOrEqual];
	[titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalMargin];
	[detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:pictureView withOffset:kVerticalMargin];
	[detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalMargin];
	[detailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalMargin];
	
**Without UIView+AutoLayout**

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:pictureView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:0.0f
                                                                  constant:kVerticalMargin]];
    [pictureView addConstraint:[NSLayoutConstraint constraintWithItem:pictureView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:80.0f]];
    [pictureView addConstraint:[NSLayoutConstraint constraintWithItem:pictureView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:40.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:pictureView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:0.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:pictureView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:0.0f
                                                                  constant:kHorizontalMargin]];
...and that's not even half of the constraints required to achieve the same effect!

Limitations
-----------

*	Will need to use `NSLayoutConstraint` directly in some cases for advanced customization of constraints (e.g. priority)
*	For simplicity, UIView+AutoLayout intentionally does not support "Leading" or "Trailing", therefore it is not intended to be used for UI that displays right-to-left languages

Problems, Suggestions, Pull Requests?
-------------------------------------

Bring 'em on! :)
I'm especially interested in hearing about any common use cases that this API does not currently address.