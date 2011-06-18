//
//  MAWebViewDelegate.m
//  Slope
//
//  Created by Brian Trzupek on 3/1/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import "AdDashWebViewDelegate.h"

@implementation AdDashWebViewDelegate 

@synthesize clientAdRequstURL;
@synthesize adView;
@synthesize adBannerView;
@synthesize dismissButton;

- (id) init {
	[super init];
	initialLoad = YES;
	return self;
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
- (void) loadAdBlockWithURL:(NSURL*)url
{
	if (url==nil) {
		url = currentURL;
	}
	// cache off the URL in case it fails
	currentURL = url;
	
	// load this into the adBannerView
	[adBannerView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.clientAdRequstURL]]];
}

- (void) loadAdBlockWithURL
{	
	// load this into the adBannerView
	[adBannerView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.clientAdRequstURL]]];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//NSLog(@"didFailLoadWithError");
	[self processErrorLoadingWebView];
}

- (void) processErrorLoadingWebView {
	// we failed to load for some reason. try again in 30 seconds
	[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loadAdBlockWithURL:) userInfo:nil repeats:NO];
	
	// hide this view
	[adBannerView setHidden:YES];
	initialLoad=YES;
	return;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"shouldStartLoadWithRequest %d", initialLoad);
	self.clientAdRequstURL = [[request URL] absoluteString];
	if (initialLoad==NO) {
		if (webView == adBannerView ){
			[adView setHidden:NO];
			[dismissButton setHidden:NO];
			[adView loadRequest:request];
			return NO;
		}
		return YES;
	} else {
		initialLoad = NO;
		return YES;
	}
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
	[adBannerView setHidden:NO];
	NSString* contents = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	
	NSString *searchForMe = @"k_ADDASH_ERROR";
	NSRange range = [contents rangeOfString : searchForMe];
	
	if (range.location != NSNotFound) {
		//NSLog(@"Error loading ad.");
		[self processErrorLoadingWebView];
	}
	
	//NSLog(@"webViewDidFinishLoad");
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
	//NSLog(@"webViewDidStartLoad");
}

@end
