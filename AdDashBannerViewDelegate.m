//
//  MAWebViewDelegate.m
//  Slope
//
//  Created by Brian Trzupek on 3/1/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import "AdDashBannerViewDelegate.h"
#import "AdDashDelegate.h"

@implementation AdDashBannerViewDelegate 

@synthesize clientAdRequstURL;
@synthesize myView;

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
    [myView setFrame:CGRectMake( 0, 0, b.size.width, __AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT)];
    [myView setBounds:CGRectMake( 0, 0, b.size.width, __AD_DASH_AD_ORIENTATION_PORTRAIT_HEIGHT)];
}

-(void) layoutLandscape {
    CGRect b = [UIScreen mainScreen].bounds;
    [myView setFrame:CGRectMake( 0, 0, b.size.height, __AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT)];
    [myView setBounds:CGRectMake( 0, 0, b.size.height, __AD_DASH_AD_ORIENTATION_LANDSCAPE_HEIGHT)];
}

-(void) detectOrientation {
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || 
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        [self layoutLandscape];
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [self layoutPortrait];
        
    }   
}

- (void) processErrorLoadingWebView {
	// we failed to load for some reason. try again in 30 seconds
	[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loadAdBlockWithURL) userInfo:nil repeats:NO];
	
	// hide this view
    [self hideView];
	initialLoad=YES;
	return;
}

- (void) loadAdBlockWithURL {	
	// load this into the adBannerView
	[myView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.clientAdRequstURL]]];
    return;
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//NSLog(@"didFailLoadWithError");
    if([error code]!=kCFURLErrorCancelled)
        [self processErrorLoadingWebView];
    return;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	self.clientAdRequstURL = [[request URL] absoluteString];
#ifdef DEBUG
    NSLog(@"Banner shouldStartLoadWithRequest %@", self.clientAdRequstURL);
#endif
    // did the click come from the bannner view or the full ad view?
    if (webView == myView) {
#ifdef DEBUG
        NSLog(@"Banner View Event");
#endif
        // Handle the click in the banner view to load the individual AD
        NSRange range = [self.clientAdRequstURL rangeOfString: @"?ad="];
        if(range.location != NSNotFound){
            AdDashDelegate* delegate = [AdDashDelegate getInstance];
            NSString* adId = [self.clientAdRequstURL substringFromIndex: range.location+4];
#ifdef DEBUG
            NSLog(@"The requested ad id: %@", adId);
#endif
            // load the ad
            [delegate getFullAdWithId:adId];
            // show the ad
            [[delegate adViewDelegate] showAd:adId];
            return NO;
        }
        
    }     
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
	[self showView];
	NSString* contents = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	
	NSString *searchForMe = @"k_ADDASH_ERROR";
	NSRange range = [contents rangeOfString : searchForMe];
	
	if (range.location != NSNotFound) {
#ifdef DEBUG
		NSLog(@"Error loading ad.");
#endif
		[self processErrorLoadingWebView];
	}
#ifdef DEBUG
	NSLog(@"Banner webViewDidFinishLoad");
#endif
    return;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self hideView];
#ifdef DEBUG
	NSLog(@"Banner webViewDidStartLoad");
#endif
    return;
}

- (void) showView {
    [myView setHidden:NO];
}

- (void) hideView {
    [myView setHidden:YES];
}
@end
