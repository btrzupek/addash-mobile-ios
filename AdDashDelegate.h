//
//  AdDashDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdDashWebViewDelegate.h"

#define __AD_DASH_SERVICE_URL       @"http://127.0.0.1/addash-application/htdocs/ad-srv.php" //@"http://www.addash.co/ad-srv.php"
#define __AD_DASH_EVENT_URL         @"http://127.0.0.1/addash-application/htdocs/ad-srv.php" //@"http://www.addash.co/event.php"
#define __AD_DASH_SERVICE_AD_BLOCK  0 // retrieve 3 d blocks for rotation
#define __AD_DASH_EVENT_NEW_GAME    1 // new game event
#define __AD_DASH_EVENT_WON_GAME    2 // won game event
#define __AD_DASH_EVENT_UPGRADED    3 // freemium upgrade event
#define __AD_DASH_EVENT_FIRST_RUN   4 // first run event
#define __AD_DASH_EVENT_IN_APP_PURCHASE 5 // in app purchase event
#define __AD_DASH_SCORE_EVENT       6 // score event
#define __AD_DASH_SERVICE_AD        7 // retrieve whole ad
#define __AD_DASH_CUSTOM_EVENT      8 // custom event
#define __AD_DASH_EVENT_UPGRADE     9 // regular upgrade event

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
    NSString*               applicationPrivateKey;
	// status of using ads
	BOOL					displayAds;
}

@property (assign) BOOL displayAds;

+ (AdDashDelegate*) getInstance;

- (NSString*) getAppBundleIdentifier;
- (NSString*) getAdvertiserIdentifier;
- (NSString*) getApplicationPrivateKey;

- (void) setAdvertiserIdentifier:(NSString *)pAdvertiserIdentifier andPrivateKey:(NSString*)pApplicationPrivateKey;

- (void) setupInParentView:(UIView*) parentView withPlacement:(int)placement;

- (void) registerViewForAdDisplay:(UIWebView*)view inParent:(UIView*)parentView;
- (void) registerViewForAdDisplay:(UIWebView*)view withAdAtLocation:(CGPoint)location inParent:(UIView*)parentView;

- (void) addFullAdViewToView:(UIWebView*)view inFrame:(CGRect)frame;

- (void) getNextAd;
- (void) dismissAdView;

- (NSData*) buildPostData:(NSMutableDictionary*)requestDict;
- (NSMutableDictionary*) buildRequestDictionary;
- (NSMutableURLRequest*) buildURLRequestWithURL:(NSString*)urlString bodyData:(NSData*)bodyData;

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
// Regular upgrade event. version to version, not free to pay
- (void) reportUpgradeEvent;
// report scoring to remote server
- (void) reportScoreEvent:(NSString*) score forPlayerAlias:(NSString*)alias withGKPlayerId:(NSString*)playerId andEmailAddress:(NSString*)email;
@end

NSString* md5( NSString *str );