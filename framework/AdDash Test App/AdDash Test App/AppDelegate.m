//
//  AppDelegate.m
//  AdDash Test App
//
//  Created by Brian Trzupek on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "AdDashDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //[[AdDashDelegate getInstance] setAdvertiserIdentifier:@"insert-your-identifier-here" andPrivateKey:@"insert-your-key-here"];
    [[AdDashDelegate getInstance] setAdvertiserIdentifier:@"*209d5fae8b2ba427d30650dd0250942ae944a0d5" andPrivateKey:@"b9145480-03de-11e1-958b-99e82af5853e"];
    [[AdDashDelegate getInstance] setDisplayAds:YES];
    [[AdDashDelegate getInstance] setupInParentView:self.viewController.view withPlacement:kAdLocationViewTop];
    
    return YES;
}

@end
