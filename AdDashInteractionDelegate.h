//
//  AdDashInteractionDelegate.h
//  Slope
//
//  Created by Brian Trzupek on 3/4/11.
//  Copyright 2011 __AdDash.co__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
	Clients who wish to perform an action in their application
    when a AD displays or when an AD closes, should inplement
	this protocol and register it with the AdDashManager
 */
@protocol AdDashInteractionDelegate 
	- (void) displayingAd;
	- (void) closingAdDisplay;

@end

