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

#import <QuartzCore/QuartzCore.h>

#import "LLPopoverView.h"
#import "LLUtils.h"
#import "LLPopoverController.h"
#import "LLPopoverLayout.h"


@implementation LLPopoverView {
    CGPoint _arrowOrigin;
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

- (id)initWithPopover:(LLPopoverController *)popover popoverLayout:(LLPopoverLayout *)popoverLayout
{
    if ( ! (self = [super initWithFrame:popoverLayout.popoverFrame]) ) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _popover = popover;
    _popoverLayout = popoverLayout;
    
    [self setupContentView];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self updateArrowOrigin];
    
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    
    UIBezierPath *popoverPath = [self popoverPath];
    [popoverPath setLineJoinStyle:kCGLineJoinRound];

    
    // The light single-point 'glow' around the popover:
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.15] setStroke];
    
    [popoverPath setLineWidth:2.0f];
    [popoverPath stroke];
    
    
    // Now, don't draw outside the path - this will clip all drawing below.
    [popoverPath addClip];
    

    // The man popover border color.
    [_popover.borderColor setFill];
    [popoverPath fill];
    
    
    // The shine gradient that covers the arrow, if it's on the top, and
    // the top portion of the popover border.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    static const CGFloat colors[] =  { 1.0f, 1.0f, 1.0f, 0.8f,
                                       1.0f, 1.0f, 1.0f, 0.0875f };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    
    // We use a single, tall, gradient and position if over the arrow if
    // the arrow is on the top, or off the top of the view so that only
    // the bottom part is visible if it's not.
    CGFloat gradientStart = self.popoverLayout.arrowDirection == LLPopoverArrowDirectionUp ? 0 : -self.popoverLayout.arrowSize.height;
    CGContextDrawLinearGradient(cgContext, gradient, CGPointMake(self.bounds.size.width * 0.5f, gradientStart), CGPointMake(self.bounds.size.width * 0.5f, gradientStart + 41), 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);

    
    // The darker single-point outline.
    [[UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:1.0] setStroke];
    
    // 2 points wide because the path is on a pixel boundry, so this causes
    // it to cover integral pixels.  The outer pixel will be clipped off
    // because we've already set a clip path, above, to the popover shape.
    [popoverPath setLineWidth:2.0f];
    [popoverPath stroke];

    
    // The single-point light highlight that surrounds the top of the top
    // border.
    CGContextSaveGState(cgContext);
    CGContextTranslateCTM(cgContext, 0, 1);
    CGFloat blendOutAt = self.popoverLayout.arrowDirection == LLPopoverArrowDirectionUp ? self.popoverLayout.arrowSize.height + 4.75f : 4.75f;
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, blendOutAt)] addClip];
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.25] setStroke];
    [popoverPath setLineWidth:2.0f];
    [popoverPath stroke];
    CGContextRestoreGState(cgContext);
    
    
    // Shadow for the entire popover.
    // System popovers have a square shadow despite the arrow sticking out
    // from them, so we do the same (perhaps this is intentional to show that,
    // though the main part is floating, the arrow is 'on' the thing it's
    // popping out from?
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self convertRect:_contentViewContainerMask.bounds fromView:_contentViewContainerMask]] CGPath];
    self.layer.shadowOffset = CGSizeMake(0.0f, 8.0f);
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 25.0f;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
}


#pragma mark - Private methods

- (void)updateArrowOrigin
{
    CGPoint originalAnchorPoint = CGPointMake(CGRectGetMidX(self.popoverLayout.targetRect), 0.0f);
    CGPoint anchorPoint = [self convertPoint:originalAnchorPoint fromView:self.popoverLayout.targetView];
    
    CGFloat minArrowPos = ceilf(self.popoverLayout.arrowSize.width * 0.5f + self.popoverLayout.cornerRadius);
    CGFloat maxArrowPos = floorf(CGRectGetWidth(self.frame) - self.popoverLayout.arrowSize.width * 0.5f - self.popoverLayout.cornerRadius) - 1.0f;
    
    CGFloat midX = ceilf([LLUtils clampValue:anchorPoint.x min:minArrowPos max:maxArrowPos]);
    
    anchorPoint.x = midX + 0.5f;
    
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
    CGRect shapeFrame = CGRectInset([self shapeFrame], 1, 1);
    
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
    CGRect shapeFrame = CGRectInset([self shapeFrame], 1, 1);
    
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
    _contentViewContainerMask = [[UIView alloc] initWithFrame:CGRectInset(containerViewFrame, 0.0f, 0.0f)];
    _contentViewContainerMask.clipsToBounds = YES;
    _contentViewContainerMask.layer.cornerRadius = 5.0f;
    CGRect contentViewContainerMaskBounds = _contentViewContainerMask.bounds;
    
    
    // To cast the inner shadow, we create a larger view, with a thick border 
    // that will cast the shadow.  The border will be masked out by the mask 
    // view.
    CGFloat shadowLayerHiddenBorderWidth = 10.0f;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectInset(contentViewContainerMaskBounds, -shadowLayerHiddenBorderWidth, -shadowLayerHiddenBorderWidth)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowView.userInteractionEnabled = NO;

    // We'll use this to create the inner shadow above the content layer.
    CALayer *shadowLayer = shadowView.layer;
    
    // add the shadowLayerHiddenBorderWidth so that the radius at the inside
    // is the same.
    shadowLayer.cornerRadius = _contentViewContainerMask.layer.cornerRadius + shadowLayerHiddenBorderWidth - 2.0f;
    
    // +1 to get the visible black line
    shadowLayer.borderWidth = shadowLayerHiddenBorderWidth - 2.5f;
    shadowLayer.borderColor = [[UIColor blackColor] CGColor];

    // And here's the shadow!
    shadowLayer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    shadowLayer.shadowOpacity = 0.75f;
    shadowLayer.shadowRadius = 2.0f;
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
