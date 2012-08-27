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

#import "LLPopoverView.h"
#import "LLUtils.h"
#import "LLPopover.h"
#import "LLPopoverLayout.h"
#import "LLStatusBarStatus.h"


@implementation LLPopoverView {
    CGPoint _arrowOrigin;
    LLStatusBarStatus *_statusBarStatus;
    UIView *_contentViewContainerMask;
}

@synthesize popover=_popover;
@synthesize popoverLayout=_popoverLayout;
@synthesize contentViewContainer=_contentViewContainer;

#pragma mark - Class lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _popover = nil;
    _popoverLayout = nil;
}

- (id)initWithPopover:(LLPopover *)popover popoverLayout:(LLPopoverLayout *)popoverLayout
{
    if ( ! (self = [super initWithFrame:popoverLayout.popoverFrame]) ) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    
    _statusBarStatus = [[LLStatusBarStatus alloc] initWithStateHandler:^(LLStatusBarState state) {
        
        if (state == LLStatusBarStateNormal)
        {
            CGRect newFrame = self.frame;
            newFrame.origin.y -= 40;
            newFrame.origin.y += 20;
            
            [self updateFrameWithFrame:newFrame animated:YES];
        }
        else if (state == LLStatusBarStateExpanded)
        {
            CGRect newFrame = self.frame;
            newFrame.origin.y -= 20;
            newFrame.origin.y += 40;
            
            [self updateFrameWithFrame:newFrame animated:YES];
        }
    }];
    
    _popover = popover;
    _popoverLayout = popoverLayout;
    
    [self setupContentView];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self updateArrowOrigin];
    
    CGRect contentFrame = _contentViewContainerMask.frame;
    contentFrame.origin = self.popoverLayout.popoverContentOffset;
    _contentViewContainerMask.frame = contentFrame;
    
    
    UIBezierPath *popoverPath = [self popoverPath];
    
    [[UIColor colorWithWhite:0.0f alpha:0.8f] setFill];
    [[UIColor colorWithWhite:1.0f alpha:0.2f] setStroke];
    
    [popoverPath addClip];
    [popoverPath fill];
    [popoverPath setLineJoinStyle:kCGLineJoinRound];
    [popoverPath setLineWidth:3.0f];
    [popoverPath stroke];
    
    
    // top shine
    UIBezierPath *shinePath = [self popoverShinePath];
    
    [[UIColor colorWithWhite:1.0f alpha:0.10f] setFill];
    [shinePath fill];
    
    
    // popover shadow
    self.layer.shadowPath = [popoverPath CGPath];
    self.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.layer.shadowOpacity = 2.0f / 3.0f;
    self.layer.shadowRadius = 20.0f;
}


#pragma mark - Private methods

- (void)updateArrowOrigin
{
    CGPoint originalAnchorPoint = CGPointMake(CGRectGetMidX(self.popoverLayout.targetRect), 0.0f);
    CGPoint anchorPoint = [self convertPoint:originalAnchorPoint fromView:self.popoverLayout.targetView];
    
    CGFloat minArrowPos = self.popoverLayout.arrowSize.width / 2 + self.popoverLayout.cornerRadius;
    CGFloat maxArrowPos = CGRectGetWidth(self.frame) - self.popoverLayout.arrowSize.width / 2 - self.popoverLayout.cornerRadius;
    
    CGFloat midX = [LLUtils clampValue:anchorPoint.x min:minArrowPos max:maxArrowPos];
    
    anchorPoint.x = midX;
    
    _arrowOrigin = anchorPoint;
}

- (CGRect)shapeFrame
{
    CGRect shapeFrame = self.bounds;
    shapeFrame.size.height -= self.popoverLayout.arrowSize.height;
    
    switch (self.popoverLayout.arrowDirection)
    {
        case LLPopoverArrowDirectionUp:
            shapeFrame.origin.y += self.popoverLayout.arrowSize.height;
            break;
            
        case LLPopoverArrowDirectionDown:
            break;
            
        case LLPopoverArrowDirectionUnknown:
            break;
    }
    
    return shapeFrame;
}

- (UIBezierPath *)popoverPathForArrowUp
{
    CGFloat arrowWidth = self.popoverLayout.arrowSize.width;
    CGFloat arrowHeight = self.popoverLayout.arrowSize.height;
    CGFloat cornerRadius = self.popoverLayout.cornerRadius;
    
    CGFloat arrowOriginX = _arrowOrigin.x;
    CGRect shapeFrame = [self shapeFrame];
    
    CGFloat maxX = CGRectGetMaxX(shapeFrame);
    CGFloat minX = CGRectGetMinX(shapeFrame);
    
    CGFloat maxY = CGRectGetMaxY(shapeFrame);
    CGFloat minY = CGRectGetMinY(shapeFrame);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // start from the arrow
    [path moveToPoint:CGPointMake(arrowOriginX - (arrowWidth / 2), minY)];
    
    // arrow
    [path addLineToPoint:CGPointMake(arrowOriginX, minY - arrowHeight)];
    [path addLineToPoint:CGPointMake(arrowOriginX + (arrowWidth / 2), minY)];
    
    //top-right line
    [path addLineToPoint:CGPointMake((minX + shapeFrame.size.width) - cornerRadius, minY)];
    
    //top-right corner
    [path addCurveToPoint:CGPointMake(maxX, minY + cornerRadius)
            controlPoint1:CGPointMake(maxX - (cornerRadius / 2), minY)
            controlPoint2:CGPointMake(maxX, minY + (cornerRadius / 2))];
    
    // right line
    [path addLineToPoint:CGPointMake(maxX, maxY - cornerRadius)];
    
    // bottom-right corner
    [path addCurveToPoint:CGPointMake(maxX - cornerRadius, maxY)
            controlPoint1:CGPointMake(maxX, maxY - (cornerRadius / 2))
            controlPoint2:CGPointMake(maxX - (cornerRadius / 2), maxY)];
    
    // bottom line
    [path addLineToPoint:CGPointMake(minX + cornerRadius, maxY)];
    
    // bottom-left corner
    [path addCurveToPoint:CGPointMake(minX, maxY - cornerRadius)
            controlPoint1:CGPointMake(minX + (cornerRadius / 2), maxY)
            controlPoint2:CGPointMake(minX, maxY - (cornerRadius / 2))];
    
    // left line
    [path addLineToPoint:CGPointMake(minX, minY + cornerRadius)];
    
    // top-left corner
    [path addCurveToPoint:CGPointMake(minX + cornerRadius, minY)
            controlPoint1:CGPointMake(minX, minY + (cornerRadius / 2))
            controlPoint2:CGPointMake(minX + (cornerRadius / 2), minY)];
    
    [path closePath];
    
    return path;
}

- (UIBezierPath *)popoverPathForArrowDown
{
    CGFloat arrowWidth = self.popoverLayout.arrowSize.width;
    CGFloat arrowHeight = self.popoverLayout.arrowSize.height;
    CGFloat cornerRadius = self.popoverLayout.cornerRadius;
    
    CGFloat arrowOriginX = _arrowOrigin.x;
    CGRect shapeFrame = [self shapeFrame];
    
    CGFloat maxX = CGRectGetMaxX(shapeFrame);
    CGFloat minX = CGRectGetMinX(shapeFrame);
    
    CGFloat maxY = CGRectGetMaxY(shapeFrame);
    CGFloat minY = CGRectGetMinY(shapeFrame);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // arrow
    [path moveToPoint:CGPointMake(arrowOriginX + (arrowWidth / 2), maxY)];
    [path addLineToPoint:CGPointMake(arrowOriginX, maxY + arrowHeight)];
    [path addLineToPoint:CGPointMake(arrowOriginX - (arrowWidth / 2), maxY)];
    
    // bottom line
    [path addLineToPoint:CGPointMake(minX + cornerRadius, maxY)];
    
    // bottom-left corner
    [path addCurveToPoint:CGPointMake(minX, maxY - cornerRadius)
            controlPoint1:CGPointMake(minX + (cornerRadius / 2), maxY)
            controlPoint2:CGPointMake(minX, maxY - (cornerRadius / 2))];
    
    // left line
    [path addLineToPoint:CGPointMake(minX, minY + cornerRadius)];
    
    // top-left corner
    [path addCurveToPoint:CGPointMake(minX + cornerRadius, minY)
            controlPoint1:CGPointMake(minX, minY + (cornerRadius / 2))
            controlPoint2:CGPointMake(minX + (cornerRadius / 2), minY)];
    
    //top line
    [path addLineToPoint:CGPointMake((minX + shapeFrame.size.width) - cornerRadius, minY)];
    
    //top-right corner
    [path addCurveToPoint:CGPointMake(maxX, minY + cornerRadius)
            controlPoint1:CGPointMake(maxX - (cornerRadius / 2), minY)
            controlPoint2:CGPointMake(maxX, minY + (cornerRadius / 2))];
    
    // right line
    [path addLineToPoint:CGPointMake(maxX, maxY - cornerRadius)];
    
    // bottom-right corner
    [path addCurveToPoint:CGPointMake(maxX - cornerRadius, maxY)
            controlPoint1:CGPointMake(maxX, maxY - (cornerRadius / 2))
            controlPoint2:CGPointMake(maxX - (cornerRadius / 2), maxY)];
    
    [path closePath];
    
    return path;
}

- (UIBezierPath *)popoverPath
{
    UIBezierPath *path = nil;
    
    switch (self.popoverLayout.arrowDirection)
    {
        case LLPopoverArrowDirectionUp:
            path = [self popoverPathForArrowUp];
            break;
            
        case LLPopoverArrowDirectionDown:
            path = [self popoverPathForArrowDown];
            break;
            
        case LLPopoverArrowDirectionUnknown:
            break;
    }
    
    return path;
}

- (UIBezierPath *)popoverShinePath
{
    CGRect shapeFrame = [self shapeFrame];
    CGRect rect = { 2.0f, 0.0f, self.bounds.size.width - 4, round(shapeFrame.size.height / 4) };
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    return path;
}

- (void)setupContentView
{
    UIEdgeInsets insets = self.popoverLayout.contentInsets;
    
    CGRect containerViewFrame = self.shapeFrame;
    containerViewFrame = UIEdgeInsetsInsetRect(containerViewFrame, insets);
    
    // This view will contain the content view, and above it, a view
    // containing the inner shadow.  It will mask out these layers
    // to fit in the popover.
    _contentViewContainerMask = [[UIView alloc] initWithFrame:containerViewFrame];
    _contentViewContainerMask.clipsToBounds = YES;
    _contentViewContainerMask.layer.cornerRadius = 6.0f;
    CGRect contentViewContainerMaskBounds = _contentViewContainerMask.bounds;
    
    
    // To cast the inner shadow, we create a larger view, with a thick border 
    // that will cast the shadow.  The border will be masked out by the mask 
    // view.
    CGFloat shadowLayerHiddenBorderWidth = 5.0f;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectInset(contentViewContainerMaskBounds, -shadowLayerHiddenBorderWidth, -shadowLayerHiddenBorderWidth)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowView.userInteractionEnabled = NO;

    // We'll use this to create the inner shadow above the content layer.
    CALayer *shadowLayer = shadowView.layer;
    
    // add the shadowLayerHiddenBorderWidth so that the radius at the inside
    // is the same.
    shadowLayer.cornerRadius = _contentViewContainerMask.layer.cornerRadius + shadowLayerHiddenBorderWidth;
    
     // +1 to get the visible black line
    shadowLayer.borderWidth = shadowLayerHiddenBorderWidth + 1.0f;
    shadowLayer.borderColor = [[UIColor blackColor] CGColor];

    // And here's the shadow!
    shadowLayer.shadowOffset = CGSizeMake(0, 1);
    shadowLayer.shadowOpacity = 2.0f / 3.0f;
    shadowLayer.shadowRadius = 2.0;
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    
    // This view will contain the real popover content.
    _contentViewContainer = [[UIView alloc] initWithFrame:contentViewContainerMaskBounds];
    _contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add the content view container first, so that it's below the shadow.
    [_contentViewContainerMask addSubview:_contentViewContainer];
    
    // Add the shadow above the content.
    [_contentViewContainerMask addSubview:shadowView];

    // Phew!
    [self addSubview:_contentViewContainerMask];
    
}


#pragma mark - Public methods

- (void)updateFrameWithFrame:(CGRect)newFrame animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = newFrame;
        }];
    }
    else
    {
        self.frame = newFrame;
    }
    
    [self setNeedsDisplay];
}

@end
