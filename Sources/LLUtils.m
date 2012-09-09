/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <tgmath.h>

#import "LLUtils.h"


@implementation LLUtils

+ (CGFloat)clampValue:(CGFloat)value min:(CGFloat)min max:(CGFloat)max
{
    if (value < min) return min;
    if (value > max) return max;
    
    return value;
}

+ (BOOL)rect:(CGRect)aRect canBeCenteredInRect:(CGRect)targetRect
{
    aRect.origin.x = (targetRect.size.width / 2) - (aRect.size.width / 2);
    aRect.origin.y = (targetRect.size.height / 2) - (aRect.size.height / 2);
    
    if (CGRectContainsRect(targetRect, aRect))
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)view:(UIView *)aView canBeCenteredInView:(UIView *)targetView
{
    CGRect targetFrame = targetView.frame;
    CGRect viewFrame = aView.frame;
    
    return [self rect:viewFrame canBeCenteredInRect:targetFrame];
}

+ (CGAffineTransform)rotationTransformForWindow:(UIWindow *)window
{
    UIInterfaceOrientation orientation = [[window rootViewController] interfaceOrientation];
    
    CGFloat rotationAngle = 0;
    switch(orientation) {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotationAngle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotationAngle = (CGFloat)M_PI * 0.5f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotationAngle = (CGFloat)M_PI * 1.5f;
            break;
    }
    
    return CGAffineTransformMakeRotation(rotationAngle);
}

+ (CGAffineTransform)rotationTransformAroundOriginForWindow:(UIWindow *)window
{
    CGAffineTransform transform = [self rotationTransformForWindow:window];
    
    CGSize windowSize = window.bounds.size;
    CGSize rotatedWindowSize = CGSizeApplyAffineTransform(windowSize, transform);
    rotatedWindowSize.width = fabs(rotatedWindowSize.width);
    rotatedWindowSize.height = fabs(rotatedWindowSize.height);
    
    
    transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-windowSize.width * 0.5f, -windowSize.height * 0.5f),
                                        transform);
    transform = CGAffineTransformConcat(transform,
                                        CGAffineTransformMakeTranslation(rotatedWindowSize.width * 0.5f, rotatedWindowSize.height * 0.5f));
    
    return transform;
}


@end
