//
//  MAWebViewDelegate.m
//  Slope
//
//  Created by Brian Trzupek on 3/1/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import "AdDashAdViewDelegate.h"
#import "AdDashDelegate.h"

@implementation AdDashAdViewDelegate 

@synthesize clientAdRequstURL;
@synthesize myView;
@synthesize dismissButton; 
@synthesize currentAdId;

- (id) init {
	self = [super init];
    if (self) {
        initialLoad = YES;
    }
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
	return self;
}

-(void) layoutPortrait {
    CGRect b = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(b.origin.x, b.origin.y, b.size.width, b.size.height);
    [myView setFrame:frame];
    [myView setBounds:frame];
}

-(void) layoutLandscape {
    CGRect b = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(b.origin.x, b.origin.y, b.size.height, b.size.width);
    [myView setFrame:frame];
    [myView setBounds:frame];
}

-(void) detectOrientation {
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || 
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        [self layoutLandscape];
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [self layoutPortrait];
        
    }   
}

/*
- (id) initWithAdBannerView:(UIWebView*)bv andAdView:(UIWebView*)av {
	[super init];
	initialLoad = YES;
	adBannerView = bv;
	adView = av;
	
	// set up delegates
	adView.delegate = self;
	return self;
}
*/

- (void) showAd:(NSString*)withId {
    self.currentAdId = withId;
    [[[AdDashDelegate getInstance] bannerViewDelegate] hideView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:myView cache:YES];
    [UIView setAnimationDuration: 0.75];
    [UIView commitAnimations];
    
    [myView setHidden:NO];
    [dismissButton setHidden:NO];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//NSLog(@"didFailLoadWithError");
    if([error code]!=kCFURLErrorCancelled)
        [self processErrorLoadingWebView];
}

- (void) processErrorLoadingWebView {
	// we failed to load for some reason. try again in 30 seconds
	// [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loadAdBlockWithURL:) userInfo:nil repeats:NO];
	// hide this view
    [[[AdDashDelegate getInstance] bannerViewDelegate] hideView];
	initialLoad=YES;
	return;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	self.clientAdRequstURL = [[request URL] absoluteString];
#ifdef DEBUG
    NSLog(@"shouldStartLoadWithRequest %@", self.clientAdRequstURL);
#endif
    
    // did the click come from the bannner view or the full ad view?
    if (webView == myView && navigationType==UIWebViewNavigationTypeLinkClicked ) {
#ifdef DEBUG
        NSLog(@"Ad View Event");
#endif
        // Handle the click in the Ad View to go to the appstore (if it is an App Store Event)
        NSString* searchForMe = @"itunes.apple.com/";
        NSRange range = [self.clientAdRequstURL rangeOfString:searchForMe];
        
        if (range.location != NSNotFound) {
            // report the event
            [[AdDashDelegate getInstance] reportAppLinkEvent:self.currentAdId];
            // load itunes view
            //[adView loadRequest:request];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.clientAdRequstURL]];
            return YES;
        }
    }
    
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [[[AdDashDelegate getInstance] bannerViewDelegate] showView];
	NSString* contents = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	
	NSString *searchForMe = @"k_ADDASH_ERROR";
	NSRange range = [contents rangeOfString : searchForMe];
	
	if (range.location != NSNotFound) {
#ifdef DEBUG
		NSLog(@"Error loading ad.");
#endif
		[self processErrorLoadingWebView];
	}
	
	//NSLog(@"webViewDidFinishLoad");
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [[[AdDashDelegate getInstance] bannerViewDelegate] hideView];
#ifdef DEBUG
	NSLog(@"Ad webViewDidStartLoad");
#endif
}

@end
