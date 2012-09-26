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

#import "LLPopoverController.h"
#import "LLPopoverView.h"
#import "LLUtils.h"
#import "LLDimmingView.h"

@interface LLPopoverController ()

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, assign, readwrite) BOOL isVisible;

@end


const char * LLPopoverSelfIsVisibleObservationContext = "LLPopoverSelfIsVisibleObservationContext";

@implementation LLPopoverController {
    LLDimmingView *_dimmingView;
    LLPopoverView *_popoverView;
}

// public
@synthesize delegate=_delegate;
@synthesize popoverLayout=_popoverLayout;
@synthesize contentViewController=_contentViewController;
@synthesize isVisible=_isVisible;

+ (UIColor *)defaultBorderColor
{
    return [UIColor colorWithRed:0.04f green:0.09f blue:0.2f alpha:1.0f];
}

#pragma mark - Class lifecycle


- (id)init
{
    if ( !(self = [super init]) ) return nil;
    
    _borderColor = [[self class] defaultBorderColor];
    
    _dimmingView = [[LLDimmingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                           dimmingColor:nil];
    
    __weak LLPopoverController *wSelf = self;
    [_dimmingView setTapBlock:^{
        [wSelf dismissPopoverAnimated:YES];
    }];
    
    _isVisible = NO;
    
    return self;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController
{
    if ( !(self = [self init]) ) return nil;
    
    self.contentViewController = contentViewController;
    _popoverLayout = [[LLPopoverLayout alloc] init];
    self.popoverLayout.contentSize = self.contentViewController.contentSizeForViewInPopover;
    
    CGRect contentFrame = {
        0.0f,
        0.0f,
        contentViewController.contentSizeForViewInPopover.width,
        contentViewController.contentSizeForViewInPopover.height
    };
    self.contentViewController.view.frame = contentFrame;

    return self;
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
        [_popoverView.contentViewContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.contentViewController.view.frame = _popoverView.contentViewContainer.bounds;
    [_popoverView.contentViewContainer addSubview:self.contentViewController.view];
    
    
    UIWindow *window = [targetView window];
    CGRect windowBounds = window.bounds;
    
    _dimmingView.transform = CGAffineTransformIdentity;

    CGAffineTransform rotationTransform = [LLUtils rotationTransformForWindow:window];
    CGRect frame = CGRectApplyAffineTransform(windowBounds, rotationTransform);
    [_dimmingView setFrame:frame];
    _dimmingView.center = CGPointMake(CGRectGetMidX(windowBounds), CGRectGetMidY(windowBounds));
    _dimmingView.transform = CGAffineTransformInvert(rotationTransform);
    [window addSubview:_dimmingView];
    
    [_dimmingView showAnimated:NO];
    
    if (
        
        // In reality, system popovers appear instantaneously even when animated.
        YES ||
        
        !animated)
    {
        [_dimmingView addSubview:_popoverView];
    }
    else
    {
        [UIView transitionWithView:_dimmingView.superview
                          duration:0.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_dimmingView addSubview:_popoverView];
                        }
                        completion:nil];
    }
    self.isVisible = YES;
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    id<LLPopoverControllerDelegate>delegate = self.delegate;
    if(!delegate ||
       ![delegate respondsToSelector:@selector(LLPopoverControllerShouldDismissPopover:)] ||
       [delegate LLPopoverControllerShouldDismissPopover:self]) {
        [_dimmingView hideAnimated:NO];
        
        void(^completionBlock)(BOOL) = ^(BOOL finished){
            self.isVisible = NO;
            if(delegate && [delegate respondsToSelector:@selector(LLPopoverControllerDidDismissPopover:)]) {
                [delegate LLPopoverControllerDidDismissPopover:self];
            }
        };
        
        if (!animated)
        {
            [_popoverView removeFromSuperview];
            [_dimmingView removeFromSuperview];
            
            completionBlock(YES);
        }
        else
        {
            [UIView transitionWithView:_dimmingView.superview
                              duration:1.0f / 3.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [_popoverView removeFromSuperview];
                                [_dimmingView removeFromSuperview];
                            }
                            completion:completionBlock];
        }
    }
}

@end
