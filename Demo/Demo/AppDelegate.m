//
//  AppDelegate.m
//  Demo
//
//  Created by Maurizio Cremaschi on 7/24/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "FMFacebookPanel.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
