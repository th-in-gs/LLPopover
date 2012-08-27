//
//  LLPTViewController.m
//  LLPopoverTest
//
//  Created by James Montgomerie on 27/08/2012.
//  Copyright (c) 2012 Things Made Out Of Other Things. All rights reserved.
//

#import "LLPTViewController.h"
#import "LLPTPopoverContentViewController.h"

#import <LLPopover/LLPopover.h>

@interface LLPTViewController () <UIGestureRecognizerDelegate>

@end

@implementation LLPTViewController {
    id _popover;
    NSUInteger _tapCount;
}

- (IBAction)receivedTap:(UITapGestureRecognizer *)sender
{
    LLPTPopoverContentViewController *contentController = [[LLPTPopoverContentViewController alloc] initWithNibName:nil bundle:nil];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad ||
       (_tapCount % 2) == 1) {
        LLPopover *popover = [[LLPopover alloc] initWithContentViewController:contentController
                                                               didShowHandler:nil
                                                               didHideHandler:nil];
        
        if((_tapCount % 4) == 0) {
            popover.borderColor = [UIColor brownColor];
        }
            
        [popover presentPopoverFromRect:(CGRect){ [sender locationInView:self.view], { 1, 1 } }
                                 inView:self.view
                               animated:YES];
        
        _popover = popover;
    } else {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:contentController];
        [popover presentPopoverFromRect:(CGRect){ [sender locationInView:self.view], { 1, 1 } }
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                               animated:YES];
        
        _popover = popover;
    }
    
    ++_tapCount;
}

@end
