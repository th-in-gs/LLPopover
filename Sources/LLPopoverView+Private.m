/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLPopoverView+Private.h"
#import "LLUtils.h"
#import "LLPopover.h"


@implementation LLPopoverView (Private)

- (void)updateArrowOrigin
{
    CGPoint originalAnchorPoint = CGPointMake(CGRectGetMidX(self.popoverLayout.targetRect), 0.0f);
    CGPoint anchorPoint = [self convertPoint:originalAnchorPoint fromView:self.popoverLayout.targetView];
    
    CGFloat minArrowPos = self.popoverLayout.arrowSize.width / 2 + self.popoverLayout.cornerRadius;
    CGFloat maxArrowPos = CGRectGetWidth(self.frame) - self.popoverLayout.arrowSize.width / 2 - self.popoverLayout.cornerRadius;
    
    CGFloat midX = [LLUtils clampValue:anchorPoint.x min:minArrowPos max:maxArrowPos];
    
    anchorPoint.x = midX;
    
    self.arrowOrigin = anchorPoint;
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
    
    CGFloat arrowOriginX = self.arrowOrigin.x;
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
    
    CGFloat arrowOriginX = self.arrowOrigin.x;
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

@end