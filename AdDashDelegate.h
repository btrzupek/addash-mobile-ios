//
//  AdDashDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdDashAdViewDelegate.h"
#import "AdDashBannerViewDelegate.h"

#define __AD_DASH_SERVICE_URL           @"https://api-v1.addash.co/ad-srv.php"
#define __AD_DASH_EVENT_URL             @"https://api-v1.addash.co/ad-srv.php"
#define __AD_DASH_SERVICE_AD_BLOCK      0 // retrieve 3 ad blocks for rotation
#define __AD_DASH_EVENT_NEW_GAME        1 // new game event
#define __AD_DASH_EVENT_WON_GAME        2 // won game event
#define __AD_DASH_EVENT_UPGRADED        3 // freemium upgrade event
#define __AD_DASH_EVENT_FIRST_RUN       4 // first run event
#define __AD_DASH_EVENT_IN_APP_PURCHASE 5 // in app purchase event
#define __AD_DASH_SCORE_EVENT           6 // score event
#define __AD_DASH_SERVICE_AD            7 // retrieve whole ad
#define __AD_DASH_CUSTOM_EVENT          8 // custom event
#define __AD_DASH_EVENT_UPGRADE         9 // regular upgrade event
#define __AD_DASH_EVENT_APP_LINK        10 // someone clicked the 'buy app' button
#define __AD_DASH_EVENT_LIKE_AD         11 // the user likes the ad
#define __AD_DASH_EVENT_DISLIKE_AD      12 // the user dislikes the ad
#define __AD_DASH_EVENT_SESSION_START   13 // user session started
#define __AD_DASH_EVENT_SESSION_END     14 // user session ended

#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_WIDTH  440
#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT 32
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_WIDTH   310
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT  32
#define __AD_DASH_FIRST_RUN_KEY  @"adDash.co.has-run-before"
#define __AD_DASH_SESSION_ID_KEY @"SessionId"

enum {
    kAdLocationViewTop = 0,
    kAdLocationViewBottom = 1,
    kAdLocationViewCenter = 2
};

@interface AdDashDelegate : NSObject {
	UIView*					adParentView;
	UIButton*				dismissButton;
	NSString*				advertiserIdentifier;
    NSString*               applicationPrivateKey;
    NSString*               sessionIdentifier;
	// status of using ads
	BOOL					displayAds;
    
    AdDashAdViewDelegate*       adViewDelegate;
    AdDashBannerViewDelegate*	bannerViewDelegate;
}

@property (assign) BOOL displayAds;
@property (retain) NSString* sessionIdentifier;
@property (strong, nonatomic) AdDashAdViewDelegate      *adViewDelegate;
@property (strong, nonatomic) AdDashBannerViewDelegate  *bannerViewDelegate;

+ (AdDashDelegate*) getInstance;

- (NSString*) getAppBundleIdentifier;
- (NSString*) getAdvertiserIdentifier;
- (NSString*) getApplicationPrivateKey;

+(BOOL) getDisplayAds;
+(void) setDisplayAds:(BOOL)display;

+ (void) setAdvertiserIdentifier:(NSString *)pAdvertiserIdentifier andPrivateKey:(NSString*)pApplicationPrivateKey;
+ (void) setupInParentView:(UIView*) parentView withPlacement:(int)placement;
+ (void) registerViewForAdDisplay:(UIWebView*)view inParent:(UIView*)parentView;
+ (void) registerViewForAdDisplay:(UIWebView*)view withAdAtLocation:(CGPoint)location inParent:(UIView*)parentView;
+ (void) getFullAdWithId:(NSString*)adId;
+ (void) dismissAdView;

// EVENTS - calling these, or creating your own allows you to gather statistics in the adDash console at www.adDash.co
// event reporting

// call this to report that the user has started a new game
+ (void) reportNewGameEvent;
// call this if you had a fremium upgrade
+ (void) reportFreemiumUpgradeEvent;
// call this if you know this is the first run of the app (handled automatically by the framework)
+ (void) reportFirstRunEvent;
// call this if the user made an in app purchase you want 
// to track (or call reportEvent with a custom code for 
// individual app purchases and their tracking
+ (void) reportInAppPurchase;
// Regular upgrade event. version to version, not free to pay
+ (void) reportUpgradeEvent:(NSString*) fromVersion to:(NSString*) toVersion;
// report scoring to remote server
+ (void) reportScoreEvent:(NSString*) score forPlayerAlias:(NSString*)alias withGKPlayerId:(NSString*)playerId andEmailAddress:(NSString*)email;
// report when an ad link is clicked for a download action
+ (void) reportAppLinkEvent:(NSString*) adId;
// report your own custom event
+ (void) reportCustomEvent:(NSString*) customType withDetail:(NSString *) detail;
// report the user like of an ad
+ (void) reportLikeAd;
// report the user dislike of an ad
+ (void) reportDislikeAd;
// analytics session reset method
+ (void) newSession;
@end

// NSString* md5( NSString *str );