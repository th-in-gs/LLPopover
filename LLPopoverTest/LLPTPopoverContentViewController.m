//
//  LLPTPopoverContentViewController.m
//  LLPopover
//
//  Created by James Montgomerie on 27/08/2012.
//  Copyright (c) 2012 Things Made Out Of Other Things. All rights reserved.
//

#import "LLPTPopoverContentViewController.h"

@interface LLPTPopoverContentViewController ()

@end

@implementation LLPTPopoverContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(400, 300);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
