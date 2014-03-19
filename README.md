UIView+AutoLayout
=================

The ultimate API for iOS Auto Layout -- impressively simple, immensely powerful. Comprised of categories on `UIView`, `NSArray`, and `NSLayoutConstraint`.

UIView+AutoLayout provides a developer-friendly interface for the vast majority of Auto Layout use cases. It is designed for clarity and simplicity, taking inspiration from the Auto Layout UI options available in Interface Builder but delivering far more flexibility and capability. The API is also highly efficient, as it adds only a thin layer of third party code and is engineered for maximum performance (for example, by automatically adding constraints to the nearest ancestor view).

API Cheat Sheet
---------------

This is just a handy overview of the core API methods. Check out the [header file](https://github.com/smileyborg/UIView-AutoLayout/blob/master/Source/UIView%2BAutoLayout.h) for the full API and documentation. A couple notes:

*	*All of the API methods begin with `auto...` for easy autocompletion!*
*	*All methods that generate constraints also automatically add the constraint(s) to the correct view, then return the newly created constraint(s) for you to optionally store for later adjustment or removal.*
*	*Many methods below also have a variant which includes a `relation:` parameter to make the constraint an inequality.*

**UIView**

*	\+ autoRemoveConstraint(s):
*	\- autoRemoveConstraintsAffectingView(AndSubviews)
*	\+ autoSetPriority:forConstraints:
*   \- autoSetContent(CompressionResistance | Hugging)PriorityForAxis:
*	\- autoCenterInSuperview:
*	\- autoAlignAxisToSuperviewAxis:
*	\- autoPinEdgeToSuperviewEdge:withInset:
*	\- autoPinEdgesToSuperviewEdges:withInsets:(excludingEdge:)
*	\- autoPinEdge:toEdge:ofView:(withOffset:)
*	\- autoAlignAxis:toSameAxisOfView:(withOffset:)
*	\- autoMatchDimension:toDimension:ofView:(withOffset: | withMultiplier:)
*	\- autoSetDimension(s)ToSize:
*	\- autoConstrainAttribute:toAttribute:ofView:(withOffset: | withMultiplier:)
*	\- autoPinTo(Top | Bottom)LayoutGuideOfViewController:withInset:

**NSArray**

*	\- autoAlignViewsToEdge:
*	\- autoAlignViewsToAxis:
*	\- autoMatchViewsDimension:
*	\- autoSetViewsDimension:toSize:
*	\- autoDistributeViewsAlongAxis:withFixedSpacing:alignment:
*	\- autoDistributeViewsAlongAxis:withFixedSize:alignment:

**NSLayoutConstraint**

*	\- autoRemove

Setup
-----
*Note: you must be developing for iOS 6.0 or later to use Auto Layout.*

**Using [CocoaPods](http://cocoapods.org)**

1.	Add the pod `UIView+AutoLayout` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

    	pod 'UIView+AutoLayout'

2.	Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.
3.	`#import UIView+AutoLayout.h` wherever you want to use the API.

	*(Hint: adding the import to your precompiled header (.pch) file once will remove the need to import the .h file everywhere!)*
4.	That's it - now go write some beautifully simple Auto Layout code!

**Manually from GitHub**

1.	Download the `UIView+AutoLayout.h` and `UIView+AutoLayout.m` files in the [Source directory](https://github.com/smileyborg/UIView-AutoLayout/tree/master/Source).
2.	Add both files to your Xcode project.
3.	`#import UIView+AutoLayout.h` wherever you want to use the API.

	*(Hint: adding the import to your precompiled header (.pch) file once will remove the need to import the .h file everywhere!)*
4.	That's it - now go write some beautifully simple Auto Layout code!

**Releases**

Releases are tagged in the git commit history using [semantic versioning](http://semver.org). Check out the [releases and release notes](https://github.com/smileyborg/UIView-AutoLayout/releases) for each version.

Usage
-----

**Example Project**

Check out the [example project](https://github.com/smileyborg/UIView-AutoLayout/blob/master/Example/) included in the repository. It contains a few demos of the API in use for various scenarios. While running the app, tap on the screen to cycle through the demos. You can rotate the device to see the constraints in action (as well as toggle the taller in-call status bar in the iOS Simulator).

**Tips and Tricks**

Check out some [Tips and Tricks](https://github.com/smileyborg/UIView-AutoLayout/wiki/Tips-and-Tricks) to keep in mind when using the API.

Limitations
-----------

*	May need to use the `NSLayoutConstraint` SDK API directly for some extremely uncommon use cases

UIView+AutoLayout vs. the rest
------------------------------

An overview of the Auto Layout options available, ordered from the lowest- to highest-level of abstraction.

*	Apple [NSLayoutConstraint SDK API](https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/NSLayoutConstraint/NSLayoutConstraint.html#//apple_ref/doc/uid/TP40010628-CH1-SW18)
 	*	Pros: Raw power
	*	Cons: Extremely verbose, tedious to write, difficult to read
*	Apple [Visual Format Language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html)
	*	Pros: Concise, convenient
	*	Cons: Doesn't support some use cases, incomplete compile-time checks, must learn syntax, hard to debug
*	Apple Interface Builder
	*	Pros: Visual, simple
	* 	Cons: Difficult for complicated layouts, cannot dynamically set constraints, not always WYSIWYG
*	**UIView+AutoLayout**
	*	Pros: Simple, efficient, built directly on the iOS SDK, minimal third party code
	*	Cons: Not the most concise or pure expression of layout code
*	High-level layout frameworks ([Masonry](https://github.com/cloudkite/Masonry), [KeepLayout](https://github.com/iMartinKiss/KeepLayout))
	*	Pros: Very clean, simple, and convenient 
	*	Cons: Heavy dependency on third party code, cannot mix with SDK APIs, potential compatibility issues with SDK changes, overloaded Objective-C syntax

Problems, Suggestions, Pull Requests?
-------------------------------------

Bring 'em on! :)

I'm especially interested in hearing about any common use cases that this API does not currently address. Feel free to add feature requests (and view current work in progress) on the [Feature Requests](https://github.com/smileyborg/UIView-AutoLayout/wiki/Feature-Requests) page of the wiki for this project.

Meta
----

Designed & maintained by Tyler Fox ([@smileyborg](https://twitter.com/smileyborg)). Distributed with the MIT license.
