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
    [AdDashDelegate setAdvertiserIdentifier:@"6bd50c40-6950-11e1-9f33-c938e9104dee" andPrivateKey:@"367e0400-87df-11e1-ad6f-c571722779e8"];
//    [AdDashDelegate setDisplayAds:YES];
    [AdDashDelegate setupInParentView:self.viewController.view withPlacement:kAdLocationViewTop];
    [AdDashDelegate reportCustomEvent:@"testing custom event" withDetail:@"test app"];
    
    return YES;
}

@end
