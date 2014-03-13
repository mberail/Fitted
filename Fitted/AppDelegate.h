//
//  AppDelegate.h
//  Fitted
//
//  Created by Maxime Berail on 26/12/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TestFlight.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;

- (void)closeSession;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
