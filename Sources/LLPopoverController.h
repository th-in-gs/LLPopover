/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/* 
 Modifications copyright (c) 2012 Things Made Out Of Other Things Ltd, http://th.ingsmadeoutofotherthin.gs/
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).

 ** It is NOT possible to have a non-attribution license to the modifications. **
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLPopoverLayout.h"

@protocol LLPopoverControllerDelegate;

/** LLPopover is a component that mimic the iPad popover on the iPhone.
 
 It works just like UIPopover: create an instance passing a content view controller and present it from a rect or UIBarButtonItem.
 */
@interface LLPopoverController : NSObject


+ (UIColor *)defaultBorderColor;

@property (nonatomic, weak) id<LLPopoverControllerDelegate> delegate;

/** The view controller that will be visible inside the popover */
@property (nonatomic, strong, readonly) UIViewController *contentViewController;

/** The model object for the popover
 
 You can modify it's properties to change various aspects of the popover creation
 */
@property (nonatomic, strong, readonly) LLPopoverLayout *popoverLayout;

/** If the popover is presented this will return YES */
@property (nonatomic, assign, readonly) BOOL isVisible;

@property (nonatomic, strong) UIColor *borderColor;


- (id)initWithContentViewController:(UIViewController *)contentViewController;

/** display the popover from a UIBarButtonItem
 
 @param barButtonItem a UIBarButtonItem object to prenset the popover from
 @param animated set to YES to fade-in the popover
 */
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                               animated:(BOOL)animated;

/** display the popover from a given rect
 
 @param targetRect present the popover from the given rect
 @param targetView the view that contains the given targetRect
 @param animated set to YES to fade-in the popover
 */
- (void)presentPopoverFromRect:(CGRect)targetRect
                        inView:(UIView *)targetView
                      animated:(BOOL)animated;

/** dismiss the popover with a fade-out animation, if enabled
 
 @param animated set to YES to fade-out the popover
 */
- (void)dismissPopoverAnimated:(BOOL)animated;

@end


@protocol LLPopoverControllerDelegate <NSObject>

@optional
/* Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
 */
- (BOOL)LLPopoverControllerShouldDismissPopover:(LLPopoverController *)popoverController;

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)LLPopoverControllerDidDismissPopover:(LLPopoverController *)popoverController;

@end

