//
//  AppDelegate.m
//  Demo
//
//  Created by Maurizio Cremaschi on 7/24/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "FMFacebookPanel.h"

static NSString * const kFacebookAppID = @"168546796612510";

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Setup Facebook with your Facebook App ID
    [[FMFacebookPanel sharedViewController] setup:kFacebookAppID];
    
    return YES;
}
							
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Use this to be sure the token is extended if needed
    [[FMFacebookPanel sharedViewController].facebook extendAccessTokenIfNeeded];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //Let Facebook handle the open url
    return [[FMFacebookPanel sharedViewController].facebook handleOpenURL:url];
}

@end
