//
//  AppDelegate.h
//  Obledoble
//
//  Created by Ellen Johansen on 3/29/12.
//  Copyright Voksenopplæringen 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
