/*
 Copyright (c) 2011 Liberati Luca http://www.liberatiluca.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 - The use of the Software in your (or your company) product, must include an attribution for my work in your (or your company) product (for example in the readme files, website and in the product itself).
 
 It's possible to have a non-attribution license, see: http://www.liberatiluca.com/components/licenses
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "LLStatusBarStatus.h"


@interface LLStatusBarStatus ()
@property (nonatomic, copy) LLStatusBarStatusStateHandler stateHandler;

- (LLStatusBarState)calculateState;
- (void)setupNotifications;
@end


@implementation LLStatusBarStatus

@synthesize stateHandler=_stateHandler;
@synthesize state=_state;
@synthesize frame=_frame;


- (id)initWithStateHandler:(LLStatusBarStatusStateHandler)stateHandler
{
    if ( !(self = [super init]) ) return nil;
    
    _frame = [[UIApplication sharedApplication] statusBarFrame];
    _state = [self calculateState];
    self.stateHandler = stateHandler;
    
    [self setupNotifications];
    
    [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        if (self.stateHandler)
        {
            self.stateHandler(self.state);
        }
    }
}


#pragma mark - Private methods

- (LLStatusBarState)calculateState
{
    LLStatusBarState state = LLStatusBarStateUnknown;
    
    if (_frame.size.height == 0.0f)
    {
        state = LLStatusBarStateHidden;
    }
    if (_frame.size.height == 20.0f)
    {
        state = LLStatusBarStateNormal;
    }
    else if(_frame.size.height == 40.0f)
    {
        state = LLStatusBarStateExpanded;
    }
    
    return state;
}

- (void)setupNotifications
{
    void(^updateStatusBarFrameBlock)(NSNotification *) = ^(NSNotification *note) {
        
        NSValue* rectValue = [[note userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
        _frame = [rectValue CGRectValue];
        self.state = [self calculateState];
    };
    
    NSNotificationCenter *notifiCenter = [NSNotificationCenter defaultCenter];
    
    [notifiCenter addObserverForName:UIApplicationWillChangeStatusBarFrameNotification
                              object:nil
                               queue:nil
                          usingBlock:updateStatusBarFrameBlock];
    
    [notifiCenter addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification
                              object:nil
                               queue:nil
                          usingBlock:updateStatusBarFrameBlock];
}

@end
