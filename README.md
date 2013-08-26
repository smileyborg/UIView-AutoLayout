UIView+AutoLayout
=================

*Originally forked from [jrturton/UIView-Autolayout](https://github.com/jrturton/UIView-Autolayout) by Tyler Fox. Distributed with the MIT License.*

Introduction
------------

A carefully-crafted category on `UIView` (and a one-method category on `NSLayoutConstraint`) that provides a simpler interface for creating Auto Layout constraints.

The goal is to provide a pleasant API for the vast majority of common Auto Layout use cases. It's designed for clarity and simplicity while simultaneously minimizing the amount of third party code. The API takes inspiration from the Auto Layout UI options available in Interface Builder.

API Cheat Sheet
---------------

This is just a handy overview of the primary methods. Check out the [header file](https://github.com/smileyborg/UIView-AutoLayout/blob/master/Source/UIView%2BAutoLayout.h) for the full API and documentation.

*Note: all of the API methods begin with `auto...` for easy autocompletion!*

**UIView**

*	\+ removeConstraint(s):
*	\+ autoSetPriority:forConstraints:
*	\- autoCenterInSuperview(AlongAxis:)
*	\- autoPinCenterAxis:toPositionInSuperview:
*	\- autoPinEdge:toPositionInSuperview:
*	\- autoPinEdge(s)ToSuperviewEdge(s):withInset(s):
*	\- autoPinEdge:toEdge:ofView:(withOffset:)
*	\- autoAlignAxis:toSameAxisOfView:(withOffset:)
*	\- autoMatchDimension:toDimension:ofView:(withOffset:)
*	\- autoMatchDimension:toDimension:ofView:(withMultiplier:)
*	\- autoSetDimension(s)ToSize:

*Advanced methods that layout an array of subviews:*

*	\- autoAlignSubviews:toEdge:
*	\- autoAlignSubviews:toAxis:
*	\- autoMatchSubviews:dimension:
*	\- autoSetSubviews:dimension:toSize:
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

**Releases**
Releases are tagged in the git commit history using [semantic versioning](http://semver.org). Check out the [Release Notes](https://github.com/smileyborg/UIView-AutoLayout/wiki/Release-Notes) for each version.

Usage
-----

**Example Project**

Check out the [example project](https://github.com/smileyborg/UIView-AutoLayout/blob/master/Example/) included in the repository. It contains a few demos of the API in use for various scenarios. While running the app, tap on the screen to cycle through the demos.

**Tips and Tricks**

Check out some [Tips and Tricks](https://github.com/smileyborg/UIView-AutoLayout/wiki/Tips-and-Tricks) to keep in mind when using the API.

Limitations
-----------

*	Will need to use the `NSLayoutConstraint` SDK API directly for some uncommon advanced use cases
*	For simplicity, UIView+AutoLayout intentionally does not support "Leading" or "Trailing", therefore it is not intended to be used for UI that displays right-to-left languages

UIView+AutoLayout vs. the rest
------------------------------

An overview of the Auto Layout options available, ordered from the lowest- to highest-level of abstraction.

*	Apple [NSLayoutConstraint SDK API](https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/NSLayoutConstraint/NSLayoutConstraint.html#//apple_ref/doc/uid/TP40010628-CH1-SW18)
 	*	Pros: Raw power
	*	Cons: Extremely verbose, tedious to write, difficult to read
*	Apple [Visual Format Language](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html)
	*	Pros: Concise, convenient
	*	Cons: Doesn't support some use cases, incomplete compile-time checks, must learn syntax, hard to debug
*	Apple Interface Builder
	*	Pros: Visual, simple
	* 	Cons: Difficult for complicated layouts, cannot dynamically set constraints	
*	**UIView+AutoLayout**
	*	Pros: Simple, built directly on top of the SDK, minimal third party code
	*	Cons: Not the most concise or pure expression of layout code
*	High-level layout frameworks ([Masonry](https://github.com/cloudkite/Masonry), [KeepLayout](https://github.com/iMartinKiss/KeepLayout))
	*	Pros: Very clean, simple, and convenient 
	*	Cons: Cannot mix with SDK APIs, total dependency on third party code, potential compatibility issues when SDK changes

Problems, Suggestions, Pull Requests?
-------------------------------------

Bring 'em on! :)

I'm especially interested in hearing about any common use cases that this API does not currently address. Feel free to add feature requests (and view current work in progress) on the [Feature Requests](https://github.com/smileyborg/UIView-AutoLayout/wiki/Feature-Requests) page of the wiki for this project.