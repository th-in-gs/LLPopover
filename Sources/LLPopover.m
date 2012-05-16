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

#import "LLPopover.h"
#import "LLPopover+Private.h"


@implementation LLPopover

// private
@synthesize didShowHandler=_didShowHandler;
@synthesize didHideHandler=_didHideHandler;
// public
@synthesize popoverLayout=_popoverLayout;
@synthesize popoverView=_popoverView;
@synthesize dimmingView=_dimmingView;
@synthesize contentVC=_contentVC;
@synthesize isVisible=_isVisible;


#pragma mark - Class lifecycle

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isVisible"];
    
    _didShowHandler = nil;
    _didHideHandler = nil;
    
    [_popoverLayout release];
    [_dimmingView release];
    [_popoverView release];
    
    [super dealloc];
}

- (id)init
{
    if ( !(self = [super init]) ) return nil;
    
    _dimmingView = [[LLDimmingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                           dimmingColor:nil];
    
    [_dimmingView setTapBlock:^{
        [self dismissPopoverAnimated:YES];
    }];
    
    _isVisible = NO;
    
    [self addObserver:self forKeyPath:@"isVisible" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController
              didShowHandler:(LLPopoverDidHideHandler)didShowHandler
              didHideHandler:(LLPopoverDidHideHandler)didHideHandler
{
    self = [self init];
    
    self.contentVC = contentViewController;
    _popoverLayout = [[LLPopoverLayout alloc] init];
    self.popoverLayout.contentSize = self.contentVC.contentSizeForViewInPopover;
    
    CGRect contentFrame = {
        0.0f,
        0.0f,
        _contentVC.contentSizeForViewInPopover.width,
        _contentVC.contentSizeForViewInPopover.height
    };
    self.contentVC.view.frame = contentFrame;
    
    self.didShowHandler = didShowHandler;
    self.didHideHandler = didHideHandler;
    
    return self;
}

+ (id)popoverWithContentViewController:(UIViewController *)contentViewController
                 didShowHandler:(LLPopoverDidHideHandler)didShowHandler
                 didHideHandler:(LLPopoverDidHideHandler)didHideHandler
{
    id popover = [[self alloc] initWithContentViewController:contentViewController
                                       didShowHandler:didShowHandler
                                       didHideHandler:didHideHandler];
    
    return [popover autorelease];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isVisible"])
    {
        if (self.isVisible)
        {
            if (self.didShowHandler)
            {
                self.didShowHandler();
            }
        }
        else
        {
            if (self.didHideHandler)
            {
                self.didHideHandler();
            }
        }
    }
}


#pragma mark - Public methods

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                               animated:(BOOL)animated
{
    UIView *targetView = (UIView *)barButtonItem;
    CGRect targetFrame = [targetView convertRect:targetView.frame toView:nil];
    
    [self presentPopoverFromRect:targetFrame inView:targetView animated:YES];
}

- (void)presentPopoverFromRect:(CGRect)targetRect
                        inView:(UIView *)targetView
                      animated:(BOOL)animated
{
    self.popoverLayout.targetView = targetView;
    self.popoverLayout.targetRect = targetRect;
    
    if (_popoverView == nil)
    {
        _popoverView = [[LLPopoverView alloc] initWithPopover:self
                                                popoverLayout:self.popoverLayout];
    }
    else
    {
        [self.popoverView.contentViewContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    _contentVC.view.frame = self.popoverView.contentViewContainer.bounds;
    [self.popoverView.contentViewContainer addSubview:_contentVC.view];
    
    
    UIWindow *window = [targetView window];
    
    [window addSubview:self.dimmingView];
    [window addSubview:self.popoverView];
    
    [self.dimmingView showAnimated:NO];
    
    if (animated == NO)
    {
        self.isVisible = YES;
    }
    else
    {
        self.popoverView.alpha = 0.0f;
        
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.popoverView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             self.isVisible = YES;
                         }];
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    [self.dimmingView hideAnimated:NO];
    
    if (animated == NO)
    {
        [self.popoverView removeFromSuperview];
        
        self.isVisible = NO;
    }
    else
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.popoverView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.popoverView removeFromSuperview];
                             self.isVisible = NO;
                         }];
    }
}

@end
