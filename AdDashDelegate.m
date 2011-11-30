//
//  AdDashDelegate.m
//  Slope
//
//  Created by Brian Trzupek on 3/2/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import "AdDashDelegate.h"
#import "sys/utsname.h"
#import "AdExtensions.h"

#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_WIDTH  310
#define __AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT 32
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_WIDTH   310
#define __AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT  32
#define __AD_DASH_FIRST_RUN_KEY @"adDash.co.has-run-before"

static AdDashDelegate* _instance;

enum {
    kAdDefaultHeight = 32,
    kAdDefaultWidth = 310
};

@implementation AdDashDelegate

@synthesize displayAds;

- (id) init {
	self = [super init];
	if (self) {
        // set the singleton
        _instance = self;
        
        // default to on
        displayAds = YES;
    }
	
	return self;
}

+ (AdDashDelegate*) getInstance {
    if(_instance)
        return _instance;
    
    @synchronized(self) {
        if (_instance == NULL) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(void) checkFirstRun {
    if(YES != [[NSUserDefaults standardUserDefaults] boolForKey:__AD_DASH_FIRST_RUN_KEY] )
    {
        // ping this event bacdk to adDash, this enables converstion tracking for your ad/promo
        [self reportFirstRunEvent];
        
    } else {
      // if it is there, is it the same value as the current version number?
        // if it is not, then this is not a first run and is an update
        // report it as such
        
        // Get the current version number from this executable (should be of form 1.x)
        NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
        NSString* savedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kCFBundleVersionKey];
        
        // See if there is a version number in the user defaults on this device, and it matches the current version number
        if ( savedVersion != NULL) {
            if( savedVersion != currentVersion ) {
                // if there is NOT, then this is the first launch of this version - track the event
                [self reportUpgradeEvent];
            }
        }
        // always update the current version
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:(NSString*)kCFBundleVersionKey];
    }
    
    // set the first app load 'cookie'
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:__AD_DASH_FIRST_RUN_KEY];
}

- (void) setAdvertiserIdentifier:(NSString *)pAdvertiserIdentifier andPrivateKey:(NSString*)pApplicationPrivateKey {
    applicationPrivateKey = pApplicationPrivateKey;
    advertiserIdentifier = pAdvertiserIdentifier;
    [self checkFirstRun];
}

-(NSString*) getAdvertiserIdentifier {
    return advertiserIdentifier;
}

-(NSString*) getApplicationPrivateKey {
    return applicationPrivateKey;
}
/*
 Primary method to use, requires no customization.
 - Pass in the view you want the Ad added to, and it will take care of the rest.
 - this method will support both portrait and landscape device orientations.
 - creates the adview, centered on X and with the placement @ enum type
 */
- (void) setupInParentView:(UIView*) parentView withPlacement:(int)placement {
    
    // create a UIWebView to add to the parent
    UIWebView* webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kAdDefaultWidth, kAdDefaultHeight)];
    // add it to the parent.
    [parentView addSubview:webview];
    // get the parent view size
    CGSize psize = parentView.bounds.size;
    float yLocation = 0;
    // determine desired placement
    switch (placement) {
        case kAdLocationViewTop:
            yLocation=kAdDefaultHeight/2;
            break;
        case kAdLocationViewBottom:
            yLocation=psize.height-kAdDefaultHeight;
            break;
        case kAdLocationViewCenter:
            yLocation=psize.height/2;
            break;
    }
    // center the webview
    webview.center = CGPointMake(psize.width/2 , yLocation);
    // register it
    [self registerViewForAdDisplay:webview inParent:parentView];
    // our work is done here
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
	
    // enable orientation tracking
    [[UIDevice currentDevice ]beginGeneratingDeviceOrientationNotifications];
    
	// ensure the advertising view - preferred height/width are correct
	if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft || 
        [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight) {
		
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

- (NSString*) getAppBundleIdentifier {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];
}

// method to load the next ad
// returned Ads can contain 1-3 individual ads
- (void) getNextAd {
    NSMutableDictionary *requestDict = [self buildRequestDictionary];
    [requestDict setObject:[NSString stringWithFormat:@"%i",__AD_DASH_SERVICE_AD_BLOCK] forKey:@"event"];
    NSData *postData = [self buildPostData:requestDict];
    NSMutableURLRequest *urlRequest = [self buildURLRequestWithURL:__AD_DASH_SERVICE_URL bodyData:postData];

	[webViewDelegate.adBannerView loadRequest:urlRequest];
	
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

- (NSMutableDictionary*) buildRequestDictionary {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceVersion = [[UIDevice currentDevice] systemVersion];

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
	NSString* deviceUID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
	NSString* deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *unixTimestamp = [NSString stringWithFormat:@"%i",(int)[[NSDate date] timeIntervalSince1970]];

    [requestDict setObject:deviceUID forKey:@"deviceUID"];
    [requestDict setObject:deviceName forKey:@"deviceName"];
    [requestDict setObject:deviceVersion forKey:@"deviceVersion"];
    [requestDict setObject:unixTimestamp forKey:@"timestamp"];    
    
	return requestDict;
}
/*
- (NSString*) buildEventRequestString {
    NSAssert(advertiserIdentifier != nil, @"Attempted to perform action without setting advertiser identifier.");
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* version = [[UIDevice currentDevice] systemVersion];
    
	NSString* deviceUID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
	NSString* requestString = [__AD_DASH_EVENT_URL stringByAppendingString:advertiserIdentifier];
	NSString* deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    requestString = [requestString stringByAppendingString:@"&_d="];
	requestString = [requestString stringByAppendingString:deviceUID];
    requestString = [requestString stringByAppendingString:@"&_mod="];
    requestString = [requestString stringByAppendingString:deviceName];
    requestString = [requestString stringByAppendingString:@"&_ver="];
    requestString = [requestString stringByAppendingString:version];
    
	return requestString;
}

- (NSURL*) buildRequestURL {
	return [NSURL URLWithString:[self buildRequestString]];
}

- (NSURL*) buildEventRequestURL:(int)eventType {
	
	NSString* requestString = [self buildEventRequestString];
	
	requestString = [requestString stringByAppendingString:@"&_eid="];
	requestString = [requestString stringByAppendingString:[[NSNumber numberWithInt:eventType] stringValue]];
	NSLog(@"Event Request URL: %@",requestString);
	return [NSURL URLWithString:requestString];
}
*/
- (void) dismissAdView {
	[webViewDelegate.adView setHidden:YES];
	[dismissButton setHidden:YES];
}

- (NSString*) buildJsonData:(NSMutableDictionary*)requestDict {
    //encode our NSMutableDictionary into a post string
    //THIS DOES NOT HANDLE ENCODINGS PROPERLY RIGHT NOW
    NSMutableArray *postArray = [NSMutableArray arrayWithCapacity:[requestDict count]];
    for (id key in requestDict) {
        [postArray addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"",key,[requestDict valueForKey:key]]];
    }
    NSString *jsonString = [postArray componentsJoinedByString:@","];
    jsonString = [NSString stringWithFormat:@"{%@}",jsonString];
    return jsonString;
}

- (NSData*) buildPostData:(NSMutableDictionary*)requestDict {
    NSAssert(advertiserIdentifier != nil, @"Attempted to perform action without setting advertiser identifier.");
    NSString *jsonString = [self buildJsonData:requestDict];
    NSData *someKey = [[NSString stringWithString:[self getApplicationPrivateKey]] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hmac = [data dataByHmacSHA256EncryptingWithKey:someKey];
    NSString *postString = [NSString stringWithFormat:@"bid=%@&advId=%@&payload=%@&signature=%@", [self getAppBundleIdentifier], advertiserIdentifier,[jsonString URLEncodeString],[hmac stringWithHexBytes]];
    NSLog(@"%@",postString);

    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    return postData;
}

- (void) reportEvent:(int) type {
	NSMutableDictionary *requestDict = [self buildRequestDictionary];
    [requestDict setObject:[NSString stringWithFormat:@"%i",type] forKey:@"event"];
    

    NSData *postData = [self buildPostData:requestDict];
    // invoke the request to the server
    NSMutableURLRequest *urlRequest = [self buildURLRequestWithURL:__AD_DASH_EVENT_URL bodyData:postData];

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

- (NSMutableURLRequest*) buildURLRequestWithURL:(NSString*)urlString bodyData:(NSData*)bodyData {
    NSURL* url = [NSURL URLWithString:urlString];
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    return urlRequest;
}

- (NSMutableDictionary*) buildScoreRequestDict:(int)eventType 
						  score:(NSString*)score 
				 forPlayerAlias:(NSString*)alias 
				 withGKPlayerId:(NSString*)playerId 
				andEmailAddress:(NSString*)email {
	
	NSMutableDictionary* requestDict = [self buildRequestDictionary];
	
	if (score==nil) {
		score=@"";
	}
	if (alias==nil) {
		alias=@"";
	}
	if (playerId==nil) {
		playerId=@"";
	}
	if (email==nil) {
		email=@"";
	}
    [requestDict setObject:[NSString stringWithFormat:@"%i",eventType] forKey:@"event"];
    [requestDict setObject:score forKey:@"score"];
    [requestDict setObject:alias forKey:@"alias"];
    [requestDict setObject:playerId forKey:@"playerId"];
    [requestDict setObject:email forKey:@"email"];

	return requestDict;
}

- (void) reportScoreEvent:(NSString*) score forPlayerAlias:(NSString*)alias withGKPlayerId:(NSString*)playerId andEmailAddress:(NSString*)email {
    NSMutableDictionary* requestDict = [self buildScoreRequestDict:__AD_DASH_SCORE_EVENT score:score forPlayerAlias:alias withGKPlayerId:playerId andEmailAddress:email];
	NSLog(@"Reporting Score Event: %@", requestDict);
	
    NSData *postData = [self buildPostData:requestDict];
    NSMutableURLRequest *urlRequest = [self buildURLRequestWithURL:__AD_DASH_EVENT_URL bodyData:postData];

	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		// receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
        NSLog(@"Communication with the remote server has failed.");
	}
	// ignore status and continue
}

- (void) reportNewGameEvent {
	[self reportEvent:__AD_DASH_EVENT_NEW_GAME];
}

- (void) reportFreemiumUpgradeEvent {
	[self reportEvent:__AD_DASH_EVENT_UPGRADED];
}

- (void) reportFirstRunEvent {
	[self reportEvent:__AD_DASH_EVENT_FIRST_RUN];
}

- (void) reportInAppPurchase {
	[self reportEvent:__AD_DASH_EVENT_IN_APP_PURCHASE];
}

- (void) reportUpgradeEvent {
	[self reportEvent:__AD_DASH_EVENT_UPGRADE];
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
