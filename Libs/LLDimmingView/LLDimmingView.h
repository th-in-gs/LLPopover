/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

typedef void(^LLDimmingViewDisplayedBlock)(BOOL isDisplayed);
typedef void(^LLDimmingViewTapBlock)(void);


/** LLDimmingView it's a view that works like the UIPopover or UIActionSheet background */
@interface LLDimmingView : UIView

/** YES if the view is visible */
@property (nonatomic, assign, readonly) BOOL isDisplayed;

+ (id)dimmingViewWithFrame:(CGRect)frame
              dimmingColor:(UIColor *)dimmingColor;

+ (id)dimmingViewWithFrame:(CGRect)frame
              dimmingColor:(UIColor *)dimmingColor
                 displayed:(LLDimmingViewDisplayedBlock)displayedBlock
                       tap:(LLDimmingViewTapBlock)tapBlock;

/** Initializer for a basic view
 
 @param frame the frame of the view
 @param dimmingColor the custom background color of the view
 */
- (id)initWithFrame:(CGRect)frame
       dimmingColor:(UIColor *)dimmingColor;

/** Initializes the view with custom blocks
 
 @param frame the frame of the view
 @param dimmingColor the custom background color of the view
 @param displayedBlock an obj-c block, called when the view will become visible
 @param tapBlock an obj-c block, called when the user taps the view
 */
- (id)initWithFrame:(CGRect)frame
       dimmingColor:(UIColor *)dimmingColor
     displayed:(LLDimmingViewDisplayedBlock)displayedBlock
           tap:(LLDimmingViewTapBlock)tapBlock;

/** set a custom obj-c block, called when the view will become visible */
- (void)setDisplayedBlock:(LLDimmingViewDisplayedBlock)displayedBlock;

/** set a custom obj-c block, called when the user taps the view */
- (void)setTapBlock:(LLDimmingViewTapBlock)tapBlock;

/** shows the view, animated or not */
- (void)showAnimated:(BOOL)animated;

/** hides the view, animated or not */
- (void)hideAnimated:(BOOL)animated;

@end
