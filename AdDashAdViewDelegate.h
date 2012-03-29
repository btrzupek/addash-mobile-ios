//
//  MAWebViewDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/1/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdDashAdViewDelegate : NSObject <UIWebViewDelegate>{
	// flag for initial content load
	BOOL            initialLoad;
	
	// maintain reference to web views
	UIWebView*		myView;
	UIButton*		dismissButton;
	
	// URL for where to retrieve ads
	NSString*		clientAdRequstURL;
	NSURL*			currentURL;
    
    NSString*       currentAdId;
}
@property (nonatomic,retain) NSString*          clientAdRequstURL;
@property (nonatomic,retain) UIWebView*         myView;
@property (nonatomic,retain) UIButton*          dismissButton;
@property (nonatomic,retain) NSString*          currentAdId;

//- (id) initWithAdBannerView:(UIWebView*)bv andAdView:(UIWebView*)av;
- (void) processErrorLoadingWebView;
- (void) showAd:(NSString*)withId;

@end
