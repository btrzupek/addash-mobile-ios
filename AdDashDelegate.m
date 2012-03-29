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

static AdDashDelegate* _instance;

enum {
    kAdDefaultHeight = 32,
    kAdDefaultWidth = 310
};

@implementation AdDashDelegate

@synthesize displayAds;
@synthesize sessionIdentifier;
@synthesize adViewDelegate;
@synthesize bannerViewDelegate;

- (id) init {
	self = [super init];
	if (self) {
        // set the singleton
        _instance = self;
        
        // default to on
        displayAds = YES;
    }
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNextAd)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
	
    return self;
}

+ (AdDashDelegate*) getInstance {
    if(_instance)
        return _instance;
    
    @synchronized(self) {
        if (_instance == NULL) {
            _instance = [[self alloc] init];
            // see if we have a previous session identifier
            _instance.sessionIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:__AD_DASH_SESSION_ID_KEY];
            if(Nil == _instance.sessionIdentifier ){
                // if not, then create one
                [_instance newSession];
            }
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
            if (NSOrderedSame != [savedVersion compare:currentVersion]) {
                // if there is NOT, then this is the first launch of this version - track the event
                [self reportUpgradeEvent: savedVersion to:currentVersion];
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
    // set scaling
    // [webview setScalesPageToFit:YES];
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
	adViewDelegate = [[AdDashAdViewDelegate alloc] init];
	bannerViewDelegate = [[AdDashBannerViewDelegate alloc] init];
    
	// set the banner view in the delegate
	bannerViewDelegate.myView = view;
	
    // enable orientation tracking
    [[UIDevice currentDevice ]beginGeneratingDeviceOrientationNotifications];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	// ensure the advertising view - preferred height/width are correct
	if ( orientation == UIInterfaceOrientationLandscapeLeft || 
        orientation == UIInterfaceOrientationLandscapeRight) {
		
		// set it at the specified location
		[view setFrame:CGRectMake(
					location.x, 
					location.y, 
					__AD_DASH_AD_ORIENTATION_LANDSCAPE_WIDTH, 
					__AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT)];
		
		CGRect b = [UIScreen mainScreen].bounds;
		frame = CGRectMake(b.origin.x, b.origin.y, b.size.height, b.size.width);
		
	} else {
		// set it at the specified location
		[view setFrame:CGRectMake(
					location.x, 
					location.y, 
					__AD_DASH_AD_ORIENTATION_PORTRAIT_WIDTH, 
					__AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT)];
		
		CGRect b = [UIScreen mainScreen].bounds;
		frame = CGRectMake(b.origin.x, b.origin.y, b.size.width, b.size.height);
	}
	
	// ensure the view is shown
	[view setHidden:NO];
	[view setAlpha:1.0f];
	
	// add the subview for displaying the 'full screen' ad
	[self addFullAdViewToView:view inFrame:frame];
	
	// set the web delegate
	view.delegate = bannerViewDelegate;
	
	// load the initial url
	[self getNextAd];
	
	return;
}

- (void) createDismissbuttonIn:(UIView*)view {	
	// need to add a control to close the ad display
	dismissButton = [[UIButton alloc] init];
	[dismissButton setFrame:CGRectMake(0, 0, 55, 55)];
	[dismissButton setTitle:@"" forState:UIControlStateNormal];
	[view addSubview:dismissButton];
	[dismissButton setHidden:YES];
	[dismissButton addTarget:self action:@selector(dismissAdView) forControlEvents:UIControlEventTouchUpInside];
	adViewDelegate.dismissButton = dismissButton;
}

- (void) addFullAdViewToView:(UIWebView*)view inFrame:(CGRect)frame {
	
	// create the view
	UIWebView* fullAdView = [[UIWebView alloc] init];
	
	// size it
	[fullAdView setFrame:frame];
	
	// hide it
	[fullAdView setHidden:YES];
    
    // set scaling
    //[theView setScalesPageToFit:YES];
	
	// add the web delegate
	adViewDelegate.myView = fullAdView;
	fullAdView.delegate = adViewDelegate;
	
    [self createDismissbuttonIn:fullAdView];
    
	// Add it to the parent
	[adParentView addSubview:fullAdView];
	
	return;
}

- (NSString*) getAppBundleIdentifier {
	return @"com.trzupek.MadLocks";//[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];
}

// method to load the next ad
// returned Ads can contain 1-3 individual ads
- (void) getNextAd {
    NSMutableDictionary *requestDict = [self buildRequestDictionary];
    [requestDict setObject:[NSString stringWithFormat:@"%i",__AD_DASH_SERVICE_AD_BLOCK] forKey:@"event"];
    NSData *postData = [self buildPostData:requestDict];
    NSMutableURLRequest *urlRequest = [self buildURLRequestWithURL:__AD_DASH_SERVICE_URL bodyData:postData];
    [bannerViewDelegate.myView loadRequest:urlRequest];
	
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

- (void) getFullAdWithId:(NSString*)adId {
    NSMutableDictionary *requestDict = [self buildRequestDictionary];
    [requestDict setObject:[NSString stringWithFormat:@"%i",__AD_DASH_SERVICE_AD] forKey:@"event"];
    [requestDict setObject:adId forKey:@"ad"];
    NSData *postData = [self buildPostData:requestDict];
    NSMutableURLRequest *urlRequest = [self buildURLRequestWithURL:__AD_DASH_SERVICE_URL bodyData:postData];
    [[adViewDelegate myView] loadRequest:urlRequest];
    
}

- (NSMutableDictionary*) buildRequestDictionary {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceVersion = [[UIDevice currentDevice] systemVersion];

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
	NSString* deviceUUID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
	NSString* deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *unixTimestamp = [NSString stringWithFormat:@"%i",(int)[[NSDate date] timeIntervalSince1970]];

    [requestDict setObject:deviceUUID forKey:@"deviceUUID"];
    [requestDict setObject:deviceName forKey:@"deviceName"];
    [requestDict setObject:deviceVersion forKey:@"deviceVersion"];
    [requestDict setObject:unixTimestamp forKey:@"timestamp"];    
    [requestDict setObject:sessionIdentifier forKey:@"sessionUUID"];
    
	return requestDict;
}

- (void) dismissAdView {
    [[[AdDashDelegate getInstance] bannerViewDelegate] showView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:adViewDelegate.myView cache:YES];
    [UIView setAnimationDuration: 0.75];
    [UIView commitAnimations];
    
	[adViewDelegate.myView setHidden:YES];
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
#ifdef DEBUG
    NSLog(@"%@",postString);
#endif
    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    return postData;
}

- (void) reportEvent:(int) type with:(NSMutableDictionary*) customDictionary {
    NSMutableDictionary *requestDict = [self buildRequestDictionary];
    [requestDict setObject:[NSString stringWithFormat:@"%i",type] forKey:@"event"];
    
    // if they supplied arguments, loop through them and merge them into our request dictionary
    // (this can override the default fields)
    if (customDictionary != NULL) {
        [customDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [requestDict setObject:obj forKey:key];
        }];
    }
    
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

- (void) reportEvent:(int) type {
    [self reportEvent:type with:NULL];
}

- (NSMutableURLRequest*) buildURLRequestWithURL:(NSString*)urlString bodyData:(NSData*)bodyData {
    NSURL* url = [NSURL URLWithString:urlString];
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    return urlRequest;
}

- (void) reportScoreEvent:(NSString*) score forPlayerAlias:(NSString*)alias withGKPlayerId:(NSString*)playerId andEmailAddress:(NSString*)email {
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
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setObject:score forKey:@"score"];
    [dict setObject:alias forKey:@"alias"];
    [dict setObject:playerId forKey:@"playerId"];
    [dict setObject:email forKey:@"email"];
    
    [self reportEvent:__AD_DASH_SCORE_EVENT with:dict];
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

- (void) reportUpgradeEvent:(NSString*) fromVersion to:(NSString*) toVersion {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:fromVersion forKey:@"fromVersion"];
    [dict setObject:toVersion forKey:@"appVersion"];
	[self reportEvent:__AD_DASH_EVENT_UPGRADE with:dict];
}

- (void) reportAppLinkEvent:(NSString*) adId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:adId forKey:@"ad"];
	[self reportEvent:__AD_DASH_EVENT_APP_LINK with:dict];
}

// report your own custom event
- (void) reportCustomEvent:(NSString*) customType withDetail:(NSString *)detail {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:customType forKey:@"customType"];
    [dict setObject:detail forKey:@"detail"];
    [self reportEvent:__AD_DASH_CUSTOM_EVENT with:dict];
}

// report the user like of an ad
- (void) reportLikeAd {
    [self reportEvent:__AD_DASH_EVENT_LIKE_AD];
}
// report the user dislike of an ad
- (void) reportDislikeAd {
    [self reportEvent:__AD_DASH_EVENT_DISLIKE_AD];
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

- (NSString*) generateSessionId {
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

- (NSString*)newSession{
    sessionIdentifier = [self generateSessionId];
    [[NSUserDefaults standardUserDefaults] setObject:sessionIdentifier forKey:(NSString*)__AD_DASH_SESSION_ID_KEY];
    return sessionIdentifier;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
