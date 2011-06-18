//
//  MAWebViewDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/1/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdDashWebViewDelegate : NSObject <UIWebViewDelegate>{
	// flag for initial content load
	BOOL initialLoad;
	
	// maintain reference to web views
	UIWebView*		adBannerView;
	UIWebView*		adView;
	UIButton*		dismissButton;
	
	// URL for where to retrieve ads
	NSString*		clientAdRequstURL;
	NSURL*			currentURL;
}
@property (nonatomic,retain) NSString*	clientAdRequstURL;
@property (nonatomic,retain) UIWebView*	adView;
@property (nonatomic,retain) UIWebView*	adBannerView;
@property (nonatomic,retain) UIButton*	dismissButton;

//- (id) initWithAdBannerView:(UIWebView*)bv andAdView:(UIWebView*)av;
- (void) processErrorLoadingWebView;

@end
