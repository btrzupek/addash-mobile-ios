//
//  AdDashDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdDashWebViewDelegate.h"

#define __AD_DASH_SERVICE_URL @"http://www.addash.co/ad-srv.php?b="
#define __AD_DASH_EVENT_NEW_GAME 1
#define __AD_DASH_EVENT_WON_GAME 2
#define __AD_DASH_EVENT_UPGRADED 3

@interface AdDashDelegate : NSObject {
	UIView*					adParentView;
	UIButton*				dismissButton;
	AdDashWebViewDelegate*	webViewDelegate;
	NSString*				advertiserIdentifier;
}

+ (AdDashDelegate*) getInstance;

- (NSString*) getAdvertiserIdentifier;

- (void) registerViewForAdDisplay:(UIWebView*)view inParent:(UIView*)parentView;
- (void) registerViewForAdDisplay:(UIWebView*)view withAdAtLocation:(CGPoint)location inParent:(UIView*)parentView;

- (void) addFullAdViewToView:(UIWebView*)view inFrame:(CGRect)frame;

- (void) getNextAd;
- (void) dismissAdView;

- (NSURL*) buildRequestURL;

// event reporting
- (void) reportEvent:(int) type;

@end

NSString* md5( NSString *str );