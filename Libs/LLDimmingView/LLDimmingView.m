/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLDimmingView.h"


@interface LLDimmingView ()
@property (nonatomic, copy) LLDimmingViewDisplayedBlock displayedBlock;
@property (nonatomic, copy) LLDimmingViewTapBlock tapBlock;
@end


@implementation LLDimmingView

// private
@synthesize displayedBlock=_displayedBlock;
@synthesize tapBlock=_tapBlock;
//public
@synthesize isDisplayed=_isDisplayed;


#pragma mark - Class lifecycle


- (id)initWithFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero))
    {
        frame = [[UIScreen mainScreen] applicationFrame];
    }
    
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    
    
    self.alpha = 0.0f;
    self.userInteractionEnabled = YES;
    
    _isDisplayed = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
       dimmingColor:(UIColor *)dimmingColor
{
    self = [self initWithFrame:frame
                  dimmingColor:dimmingColor
                     displayed:nil
                           tap:nil];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
       dimmingColor:(UIColor *)dimmingColor
          displayed:(LLDimmingViewDisplayedBlock)displayedBlock
                tap:(LLDimmingViewTapBlock)tapBlock
{
    self = [self initWithFrame:frame];
    
    if (dimmingColor)
    {
        self.backgroundColor = [dimmingColor colorWithAlphaComponent:0.85f];
    }
    
    self.displayedBlock = displayedBlock;
    self.tapBlock = tapBlock;
    
    return self;
}

+ (id)dimmingViewWithFrame:(CGRect)frame
              dimmingColor:(UIColor *)dimmingColor
{
    id view = [[self class] dimmingViewWithFrame:frame
                                    dimmingColor:dimmingColor
                                       displayed:nil
                                             tap:nil];
    
    return view;
}

+ (id)dimmingViewWithFrame:(CGRect)frame
              dimmingColor:(UIColor *)dimmingColor
                 displayed:(LLDimmingViewDisplayedBlock)displayedBlock
                       tap:(LLDimmingViewTapBlock)tapBlock
{
    id view = [[self alloc] initWithFrame:frame
                             dimmingColor:dimmingColor
                                displayed:displayedBlock
                                      tap:tapBlock];
    
    return view;
}


#pragma mark - Private methods

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (self.tapBlock)
    {
        self.tapBlock();
    }
}


#pragma mark - Public methods

- (void)showAnimated:(BOOL)animated
{
    self.hidden = NO;
    
    if (animated == NO)
    {
        _isDisplayed = YES;
        self.alpha = 1.0f;
        
        if (self.displayedBlock)
        {
            self.displayedBlock(self.isDisplayed);
        }
    }
    else
    {
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.alpha = 1.0f;
                             
                         } completion:^(BOOL finished) {
                             
                             _isDisplayed = YES;
                             
                             if (self.displayedBlock)
                             {
                                 self.displayedBlock(self.isDisplayed);
                             }
                         }
        ];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated == NO)
    {
        _isDisplayed = NO;
        self.alpha = 0.0f;
        self.hidden = YES;
        
        if (self.displayedBlock)
        {
            self.displayedBlock(self.isDisplayed);
        }
    }
    else
    {
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.alpha = 0.0f;
                             
                         } completion:^(BOOL finished) {
                             
                             _isDisplayed = NO;
                             self.hidden = YES;
                             
                             if (self.displayedBlock)
                             {
                                 self.displayedBlock(self.isDisplayed);
                             }
                         }
        ];
    }
}

@end
