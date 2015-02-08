//
//  AppDelegate.m
//  layout practice
//
//  Created by James Coughlan on 31/01/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import "AppDelegate.h"
#import "BKSFeatureManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[BKSFeatureManager sharedManager] enableRegularLogging];
    [[BKSFeatureManager sharedManager] enableFileLogging];
    [[BKSFeatureManager sharedManager] enableZeroPushNotificationWithKey:@"iosdev_qGWyxZ1GpyrWyo7DF3Gz" andDelegate:self];
    [[BKSFeatureManager sharedManager] enableCoreData];
    [[BKSFeatureManager sharedManager] enableGoogleAnalyticsWithKey:@"UA-59197069-1" withLogging:NO];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenData
{
    [[BKSFeatureManager sharedManager] zeroPushNotificationSuccess:tokenData];
    
    // For instance you can associate it with a user's email address
    // [[ZeroPush shared] subscribeToChannel:@"user@example.com"];
    // You can then use the /broadcast endpoint to notify all devices subscribed to that email address. No need to save tokens!
    // Don't forget to unsubscribe from the channel when the user logs out of your app!
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[BKSFeatureManager sharedManager] zeroPushNotificationFail:error];
    //NSLog(@"%@", [error description]);
    //Common reason for errors:
    //  1.) Simulator does not support receiving push notifications
    //  2.) User rejected push alert
    //  3.) "no valid 'aps-environment' entitlement string found for application"
    //      This means your provisioning profile does not have Push Notifications configured. https://zeropush.com/documentation/generating_certificates
}

@end
