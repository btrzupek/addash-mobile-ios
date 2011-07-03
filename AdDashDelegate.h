//
//  AdDashDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdDashWebViewDelegate.h"

#define __AD_DASH_SERVICE_URL     @"http://www.addash.co/ad-srv.php?b="
#define __AD_DASH_EVENT_NEW_GAME  1
#define __AD_DASH_EVENT_WON_GAME  2
#define __AD_DASH_EVENT_UPGRADED  3
#define __AD_DASH_EVENT_FIRST_RUN 4
#define __AD_DASH_EVENT_IN_APP_PURCHASE 5

enum {
    kAdLocationViewTop = 0,
    kAdLocationViewBottom = 1,
    kAdLocationViewCenter = 2
};

@interface AdDashDelegate : NSObject {
	UIView*					adParentView;
	UIButton*				dismissButton;
	AdDashWebViewDelegate*	webViewDelegate;
	NSString*				advertiserIdentifier;
}

+ (AdDashDelegate*) getInstance;

- (id) initInParentView:(UIView*) parentView withPlacement:(int)placement andAdvertiserId:(NSString*)advId;

- (NSString*) getAdvertiserIdentifier;

- (void) registerViewForAdDisplay:(UIWebView*)view inParent:(UIView*)parentView;
- (void) registerViewForAdDisplay:(UIWebView*)view withAdAtLocation:(CGPoint)location inParent:(UIView*)parentView;

- (void) addFullAdViewToView:(UIWebView*)view inFrame:(CGRect)frame;

- (void) getNextAd;
- (void) dismissAdView;

- (NSURL*) buildRequestURL;

// EVENTS - calling these, or creating your own allows you to gather statistics in the adDash console at www.adDash.co
// event reporting
- (void) reportEvent:(int) type;
// call this to report that the user has started a new game
- (void) reportNewGameEvent;
// call this if you had a fremium upgrade
- (void) reportFreemiumUpgradeEvent;
// call this if you know this is the first run of the app (handled automatically by the framework)
- (void) reportFirstRunEvent;
// call this if the user made an in app purchase you want 
// to track (or call reportEvent with a custom code for 
// individual app purchases and their tracking
- (void) reportInAppPurchase;
@end

NSString* md5( NSString *str );