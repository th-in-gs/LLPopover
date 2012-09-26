//
//  LLPTViewController.m
//  LLPopoverTest
//
//  Created by James Montgomerie on 27/08/2012.
//  Copyright (c) 2012 Things Made Out Of Other Things. All rights reserved.
//

#import "LLPTViewController.h"
#import "LLPTPopoverContentViewController.h"

#import <LLPopover/LLPopoverController.h>

@interface LLPTViewController () <UIGestureRecognizerDelegate, UIPopoverControllerDelegate, LLPopoverControllerDelegate>

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
        LLPopoverController *popover = [[LLPopoverController alloc] initWithContentViewController:contentController];
        popover.delegate = self;
        
        if((_tapCount % 4) == 0) {
            popover.borderColor = [UIColor brownColor];
        }
            
        [popover presentPopoverFromRect:(CGRect){ [sender locationInView:self.view], { 1, 1 } }
                                 inView:self.view
                               animated:YES];
        
        _popover = popover;
    } else {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:contentController];
        popover.delegate = self;
        
        [popover presentPopoverFromRect:(CGRect){ [sender locationInView:self.view], { 1, 1 } }
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                               animated:YES];
        
        _popover = popover;
    }
    
    ++_tapCount;
}


- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if(rand() / (RAND_MAX / 2)) {
        NSLog(@"Dismissing UIPopover!");
        return YES;
    } else {
        NSLog(@"Not dismissing UIPpover!");
        return NO;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"UIPopover dismissed!");
}


- (BOOL)LLPopoverControllerShouldDismissPopover:(LLPopoverController *)popoverController
{
    if(rand() / (RAND_MAX / 2)) {
        NSLog(@"Dismissing LLPopover!");
        return YES;
    } else {
        NSLog(@"Not dismissing LLPopover!");
        return NO;
    }
}

- (void)LLPopoverControllerDidDismissPopover:(LLPopoverController *)popoverController
{
    NSLog(@"LLPopover dismissed!");
}

@end
