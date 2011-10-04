/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLPopoverView.h"
#import "LLPopoverView+Private.h"
#import "LLPopover.h"
#import "LLPopoverLayout.h"
#import "LLStatusBarStatus.h"


@implementation LLPopoverView

// private
@synthesize statusBarStatus=_statusBarStatus;
@synthesize arrowOrigin=_arrowOrigin;
// public
@synthesize popover=_popover;
@synthesize popoverLayout=_popoverLayout;
@synthesize contentViewContainer=_contentViewContainer;


#pragma mark - Class lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _popover = nil;
    _popoverLayout = nil;
    
    [_contentViewContainer release];
    [_statusBarStatus release];
    
    [super dealloc];
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
    
    CGRect contentFrame = self.contentViewContainer.frame;
    contentFrame.origin = self.popoverLayout.popoverContentOffset;
    self.contentViewContainer.frame = contentFrame;
    
    
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
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 18.0f;
}


#pragma mark - Private methods

- (void)setupContentView
{
    CGRect containerViewFrame = { 0.0f, 0.0f, self.popoverLayout.contentSize.width, self.popoverLayout.contentSize.height };
    
    //TODO: move to it's own class to optimize rendering
    //TODO: add an inner shadow using CAGradientLayer
    _contentViewContainer = [[UIView alloc] initWithFrame:containerViewFrame];
    
    self.contentViewContainer.clipsToBounds = YES;
    self.contentViewContainer.layer.cornerRadius = 6.0f;
    self.contentViewContainer.layer.borderColor = [[UIColor blackColor] CGColor];
    self.contentViewContainer.layer.borderWidth = 1.0f;
    
    [self addSubview:_contentViewContainer];
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
