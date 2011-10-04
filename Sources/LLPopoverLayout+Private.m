/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLPopoverLayout+Private.h"


@implementation LLPopoverLayout (Private)

- (LLScreenMatrix)calculateScreenMatrix
{
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    
    LLScreenMatrix screenMatrix;
    
    // segment of a 3x3 matrix
    CGFloat segmentWidth = ceilf((appWindow.bounds.size.width / 3) * 100) / 100;
    CGFloat segmentHeight = ceilf((appWindow.bounds.size.height / 3) * 100) / 100;
    
    CGSize segmentSize = CGSizeMake(segmentWidth, segmentHeight);
    
    for (int column = 0; column <= 2; column++)
    {
        for (int row = 0; row <= 2; row++)
        {
            CGRect segmentRect = CGRectZero;
            
            segmentRect.origin.x = column * segmentSize.width;
            segmentRect.origin.y = row * segmentSize.height;
            segmentRect.size = segmentSize;
            
            if (column == 0)
            {
                if (row == 0)
                {
                    screenMatrix.topLeft = segmentRect;
                }
                else if (row == 1)
                {
                    screenMatrix.centerLeft = segmentRect;
                }
                else if (row == 2)
                {
                    screenMatrix.bottomLeft = segmentRect;
                }
                
            }
            else if(column == 1)
            {
                if (row == 0)
                {
                    screenMatrix.topCenter = segmentRect;
                }
                else if (row == 1)
                {
                    screenMatrix.center = segmentRect;
                }
                else if (row == 2)
                {
                    screenMatrix.bottomCenter = segmentRect;
                }
            }
            else if(column == 2)
            {
                if (row == 0)
                {
                    screenMatrix.topRight = segmentRect;
                }
                else if (row == 1)
                {
                    screenMatrix.centerRight = segmentRect;
                }
                else if (row == 2)
                {
                    screenMatrix.bottomRight = segmentRect;
                }
            }
        }
    }
    
    return screenMatrix;
}

@end
