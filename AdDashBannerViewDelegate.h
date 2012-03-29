//
//  AdDashBannerViewDelegate.h
//  MadLocks
//
//  Created by Brian Trzupek on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdDashBannerViewDelegate : NSObject <UIWebViewDelegate>{
	// flag for initial content load
	BOOL            initialLoad;
	// maintain reference to web views
	UIWebView*		myView;
	// URL for where to retrieve ads
	NSString*		clientAdRequstURL;
}
@property (nonatomic,retain) NSString*          clientAdRequstURL;
@property (nonatomic,retain) UIWebView*         myView;

- (void) showView;
- (void) hideView;
@end
