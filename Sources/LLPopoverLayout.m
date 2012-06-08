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
#import "LLPopoverLayout+Private.h"
#import "LLUtils.h"


@implementation LLPopoverLayout

// private
@synthesize screenMatrix=_screenMatrix;
// public
@synthesize arrowDirection=_arrowDirection;
@synthesize arrowSize=_arrowSize;
@synthesize cornerRadius=_cornerRadius;
@synthesize contentInsets=_contentInsets;
@synthesize contentSize=_contentSize;
@synthesize popoverContentOffset=_popoverContentOffset;
@synthesize popoverFrame=_popoverFrame;
@synthesize popoverFrameInsets=_popoverFrameInsets;
@synthesize popoverMaxSize=_popoverMaxSize;
@synthesize popoverMinSize=_popoverMinSize;
@synthesize targetOffset=_targetOffset;
@synthesize targetRect=_targetRect;
@synthesize targetView=_targetView;


#pragma mark - Class lifecycle

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"targetRect"];
    
    _targetView = nil;
    
    [super dealloc];
}

- (id)init
{
    if ( !(self = [super init]) ) return nil;
    
    self.arrowSize = CGSizeMake(36.0f, 20.0f);
    self.cornerRadius = 8.0f;
    self.contentInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    self.contentSize = CGSizeMake(100.0f, 80.0f);
    self.popoverFrameInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    self.popoverMaxSize = CGSizeMake(300.0f, 420.0f);
    self.popoverMinSize = CGSizeMake(120.0f, 70.0f);
    self.targetOffset = 0.0f;
    self.targetRect = CGRectZero;
    
    [self addObserver:self forKeyPath:@"targetRect" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LLPopoverLayout *copy = [[LLPopoverLayout allocWithZone:zone] init];
    
    copy.arrowSize = self.arrowSize;
    copy.cornerRadius = self.cornerRadius;
    copy.contentSize = self.contentSize;
    copy.contentInsets = self.contentInsets;
    copy.popoverFrameInsets = self.popoverFrameInsets;
    copy.targetOffset = self.targetOffset;
    copy.targetRect = self.targetRect;
    copy.targetView = self.targetView;
    
    return copy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"targetRect"])
    {
        [self updateArrowDirection];
        [self updatePopoverFrame];
    }
}


#pragma mark - Getters / Setters

- (CGPoint)popoverContentOffset
{
    CGPoint offset = { self.contentInsets.left, self.contentInsets.top };
    
    switch (self.arrowDirection)
    {
        case LLPopoverArrowDirectionUp:
            offset.y += self.arrowSize.height;
            break;
            
        case LLPopoverArrowDirectionDown:
            break;
            
        case LLPopoverArrowDirectionUnknown:
            break;
    }
    
    return offset;
}


#pragma mark - Public methods

- (void)updateArrowDirection
{
    LLPopoverArrowDirection arrowDirection = LLPopoverArrowDirectionUnknown;
    
    CGRect convertedTargetRect = [self.targetView convertRect:self.targetRect toView:nil];
    
    self.screenMatrix = [self calculateScreenMatrix];
    
    if (CGRectIntersectsRect(self.screenMatrix.topLeft, convertedTargetRect) ||
        CGRectIntersectsRect(self.screenMatrix.topCenter, convertedTargetRect) ||
        CGRectIntersectsRect(self.screenMatrix.topRight, convertedTargetRect))
    {
        arrowDirection = LLPopoverArrowDirectionUp;
    }
    else if (CGRectIntersectsRect(self.screenMatrix.centerLeft, convertedTargetRect) ||
             CGRectIntersectsRect(self.screenMatrix.center, convertedTargetRect) ||
             CGRectIntersectsRect(self.screenMatrix.centerRight, convertedTargetRect))
    {
        arrowDirection = LLPopoverArrowDirectionDown;
    }
    else if (CGRectIntersectsRect(self.screenMatrix.bottomLeft, convertedTargetRect) ||
             CGRectIntersectsRect(self.screenMatrix.bottomCenter, convertedTargetRect) ||
             CGRectIntersectsRect(self.screenMatrix.bottomRight, convertedTargetRect))
    {
        arrowDirection = LLPopoverArrowDirectionDown;
    }
    
    _arrowDirection = arrowDirection;
}

- (void)updatePopoverFrame
{
    CGRect frame = CGRectZero;
    
    UIWindow *window = self.targetView.window;
    CGRect convertedTargetRect = [window convertRect:self.targetRect fromView:self.targetView];
    
    // calculate the frame
    frame.size.width = self.contentSize.width + self.contentInsets.left + self.contentInsets.right;
    frame.size.width = [LLUtils clampValue:frame.size.width min:self.popoverMinSize.width max:self.popoverMaxSize.width];
    
    frame.size.height = self.contentSize.height + self.contentInsets.top + self.contentInsets.bottom + self.arrowSize.height;
    frame.size.height = [LLUtils clampValue:frame.size.height min:self.popoverMinSize.height max:self.popoverMaxSize.height];
    
    frame.origin.y = 0.0f;
    frame.origin.x = CGRectGetMidX(convertedTargetRect) - (frame.size.width / 2);
    
    switch (self.arrowDirection)
    {
        case LLPopoverArrowDirectionUp:
            frame.origin.y += CGRectGetMaxY(convertedTargetRect) + self.targetOffset;
            break;
            
        case LLPopoverArrowDirectionDown:
            frame.origin.y += CGRectGetMinY(convertedTargetRect) - frame.size.height - self.targetOffset;
            break;
            
        case LLPopoverArrowDirectionUnknown:
            
            break;
    }
    
    // move the frame based on targetRect and the window bounds
    CGRect applicationFrame = [[window screen] applicationFrame];
    CGRect windowBounds = CGRectIntersection(applicationFrame, window.bounds);
    
    if (CGRectGetMinX(frame) < CGRectGetMinX(windowBounds) + self.popoverFrameInsets.left) {
        frame.origin.x = CGRectGetMinX(windowBounds) + self.popoverFrameInsets.left;
    } else if (CGRectGetMaxX(frame) > CGRectGetMaxX(windowBounds) - self.popoverFrameInsets.right) {
        frame.origin.x = CGRectGetMaxX(windowBounds) - CGRectGetWidth(frame) - self.popoverFrameInsets.right;
    }
    
    if (CGRectGetMinY(frame) < CGRectGetMinY(windowBounds) + self.popoverFrameInsets.top) {
        CGFloat diff = CGRectGetMinY(windowBounds) + self.popoverFrameInsets.top - CGRectGetMinY(frame);
        frame.origin.y += diff;
        frame.size.height -= diff;
    } else if (CGRectGetMaxY(frame) > CGRectGetMaxY(windowBounds) - self.popoverFrameInsets.bottom) {
        CGFloat diff = self.popoverFrameInsets.bottom - CGRectGetMinY(frame);
        frame.origin.y -= diff;
        frame.size.height -= diff;
    }
        
    _popoverFrame = frame;
}

@end