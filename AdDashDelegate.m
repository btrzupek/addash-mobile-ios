//
//  AdDashDelegate.m
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import "AdDashDelegate.h"
#import <CommonCrypto/CommonDigest.h>

#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_WIDTH 310
#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT 32
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_WIDTH 310
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT 32
#define kSALT @"1app4moreTime@"

static AdDashDelegate* _instance;

@implementation AdDashDelegate

- (id) init {
	[super init];
	
	// cache off the advertiser identifier
	advertiserIdentifier = [self getAdvertiserIdentifier];
	
	// set the static accessor object
	_instance = self;
	
	return self;
}

+ (AdDashDelegate*) getInstance {
	return _instance;
}

// method to allow a view to be registered to display ads
// 310x48 ad size - landscape
// Ad view inset by 20px surrounding
// pass in the AD banner view and location where you want it, if different from where it is
// view should be a initialized view already in a view hierarchy
- (void) registerViewForAdDisplay:(UIWebView*)view inParent:(UIView*)parentView
{
	[self registerViewForAdDisplay:view withAdAtLocation:[view frame].origin inParent:parentView];
}

- (void) registerViewForAdDisplay:(UIWebView*)view withAdAtLocation:(CGPoint)location inParent:(UIView*)parentView
{
	CGRect frame;
	
	// Set the parent
	adParentView = parentView;
	
	// init a web view delegate for this view
	webViewDelegate = [[AdDashWebViewDelegate alloc] init];
	
	// set the banner view in the delegate
	webViewDelegate.adBannerView = view;
	
	// ensure the advertising view - preferred height/width are correct
	if ([UIDevice currentDevice].orientation == 
		UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight) {
		
		// set it at the specified location
		[view setFrame:CGRectMake(
					location.x, 
					location.y, 
					__AD_DASH_AD_ORIENTATION_LANDSCAPE_WIDTH, 
					__AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT)];
		
		CGRect b = [UIScreen mainScreen].bounds;
		// 20 px border
		b.origin.x+=20;
		b.origin.y+=20;
		b.size.width-=40;
		b.size.height-=40;
		frame = CGRectMake(b.origin.x, b.origin.y, b.size.height, b.size.width);
		
	} else {
		// set it at the specified location
		[view setFrame:CGRectMake(
					location.x, 
					location.y, 
					__AD_DASH_AD_ORIENTATION_PORTRAIT_WIDTH, 
					__AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT)];
		
		CGRect b = [UIScreen mainScreen].bounds;
		// 20 px border
		b.origin.x+=20;
		b.origin.y+=20;
		b.size.width-=40;
		b.size.height-=40;
		frame = CGRectMake(b.origin.x, b.origin.y, b.size.width, b.size.height);
	}
	
	// ensure the view is shown
	[view setHidden:NO];
	[view setAlpha:1.0f];
	
	// add the subview for displaying the 'full screen' ad
	[self addFullAdViewToView:view inFrame:frame];
	
	// set the web delegate
	view.delegate = webViewDelegate;
	
	// load the initial url
	[self getNextAd];
	
	return;
}

- (void) addFullAdViewToView:(UIWebView*)view inFrame:(CGRect)frame {
	
	// create the view
	UIWebView* theView = [[UIWebView alloc] init];
	
	// size it
	[theView setFrame:frame];
	
	// hide it
	[theView setHidden:YES];
	
	// add the web delegate
	webViewDelegate.adView = theView;
	theView.delegate = webViewDelegate;
	
	// need to add a control to close the ad display
	dismissButton = [[UIButton alloc] init];
	[dismissButton setFrame:CGRectMake(0, 0, 35, 35)];
	[dismissButton setTitle:@"" forState:UIControlStateNormal];
	[theView addSubview:dismissButton];
	[dismissButton setHidden:YES];
	[dismissButton addTarget:self action:@selector(dismissAdView) forControlEvents:UIControlEventTouchUpInside];
	webViewDelegate.dismissButton = dismissButton;
	
	// Add it to the parent
	[adParentView addSubview:theView];
	
	return;
}

- (NSString*) getAdvertiserIdentifier {
	// TODO: encode or hash this
	// return the bundle identifier for this application, this will be the advertiser identifier
	
	//return md5( [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey] );
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];
}

// method to load the next ad
// returned Ads can contain 1-3 individual ads
- (void) getNextAd {
	// pass the client identifier
	[webViewDelegate.adBannerView loadRequest:[NSURLRequest requestWithURL:[self buildRequestURL]]];
	
	// server will 
	// (1) see if this is an active identifier
	// -- if not it will return an error.
	// (2) determine if this client is serving their own ad series
	// -- if they are then they will get their own ads
	// (3) if they are active and are not serving their own
	// -- query for active ads that can be shown for this client
	// ---- active ads are ads that are
	// (3.a) Not blacklisted by this client
	// (3.b) Still active (account is not maxed/over)
	// (3.c) Acceptable for this 'category' of game
	// (3.d) Valid for this date (ads are presented in day long blocks)
	// (3.e) Go get 3 ads that meet this criteria.
	// (4) Return 1-3 ads
	
}

- (NSString*) buildRequestString {
	//NSString* deviceUID = md5( [[UIDevice currentDevice] uniqueIdentifier] );
	NSString* deviceUID = [[UIDevice currentDevice] uniqueIdentifier];
	NSString* requestString = [__AD_DASH_SERVICE_URL stringByAppendingString:advertiserIdentifier];
	requestString = [requestString stringByAppendingString:@"&_d="];
	requestString = [requestString stringByAppendingString:deviceUID];
	return requestString;
}

- (NSURL*) buildRequestURL {
	return [NSURL URLWithString:[self buildRequestString]];
}

- (NSURL*) buildEventRequestURL:(int)eventType {
	
	NSString* requestString = [self buildRequestString];
	
	requestString = [requestString stringByAppendingString:@"&_eid="];
	requestString = [requestString stringByAppendingString:[[NSNumber numberWithInt:eventType] stringValue]];
	
	return [NSURL URLWithString:requestString];
}

- (void) dismissAdView {
	[webViewDelegate.adView setHidden:YES];
	[dismissButton setHidden:YES];
}

- (void) reportEvent:(int) type {
	//NSMutableData*	receivedData;
	
	// construct the event url
	NSURL* url = [self buildEventRequestURL:type];
	
	// invoke the request to the server
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		// receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
	}
	
	// ignore status and continue
	
}

- (void) reportNewGameEvent {
	[self reportEvent:__AD_DASH_EVENT_NEW_GAME];
}

- (void) reportFreemiumUpgradeEvent {
	[self reportEvent:__AD_DASH_EVENT_UPGRADED];
}

// URLConnection delegate methods (minimal methods to be functional
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

} 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
}


@end

NSString* md5( NSString *str )
{
	const char *cStr = [[str stringByAppendingString:kSALT] UTF8String];
	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}