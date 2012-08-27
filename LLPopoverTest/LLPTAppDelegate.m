//
//  LLPTAppDelegate.m
//  LLPopoverTest
//
//  Created by James Montgomerie on 27/08/2012.
//  Copyright (c) 2012 Things Made Out Of Other Things. All rights reserved.
//

#import "LLPTAppDelegate.h"

#import "LLPTViewController.h"

@implementation LLPTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[LLPTViewController alloc] initWithNibName:@"LLPTViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
