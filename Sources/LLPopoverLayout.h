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

typedef enum
{
    LLPopoverArrowDirectionUnknown,
    LLPopoverArrowDirectionUp,
    LLPopoverArrowDirectionDown
} LLPopoverArrowDirection;


/** LLPopoverLayout is the model object used to construct to the popover */
@interface LLPopoverLayout : NSObject <NSCopying>

/** direction of the arrow */
@property (nonatomic, assign, readonly) LLPopoverArrowDirection arrowDirection;

/** size of the arrow */
@property (nonatomic, assign) CGSize arrowSize;

/** corner radius of the popover shape */
@property (nonatomic, assign) CGFloat cornerRadius;

/** insets of the view controller container */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/** size of the view controller container */
@property (nonatomic, assign) CGSize contentSize;

/** offset of the view controller container, calculated using contentInsets */
@property (nonatomic, assign, readonly) CGPoint popoverContentOffset;

/** calculated frame for the popover view */
@property (nonatomic, assign, readonly) CGRect popoverFrame;

/** insets of the popover shape */
@property (nonatomic, assign) UIEdgeInsets popoverFrameInsets;

/** popover shape maximum size */
@property (nonatomic, assign) CGSize popoverMaxSize;

/** popover shape minimum size */
@property (nonatomic, assign) CGSize popoverMinSize;

/** offset from the target view */
@property (nonatomic, assign) CGFloat targetOffset;

/** the rect from where present the popover */
@property (nonatomic, assign) CGRect targetRect;

/** the target that contains targetRect */
@property (nonatomic, weak) UIView *targetView;

- (void)updateArrowDirection;
- (void)updatePopoverFrame;

@end
