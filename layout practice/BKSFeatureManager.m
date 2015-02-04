//
//  BKS Feature Manager.m
//  BKS base project
//
//  Created by James Coughlan on 02/02/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import "BKSFeatureManager.h"
#import <ZeroPush.h>
#import <GAI.h>

@implementation BKSFeatureManager

+ (BKSFeatureManager*)sharedManager {
    static BKSFeatureManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(id)init
{
    self = [super init];
    usesPushNotifications = NO;
    usesGoogleAnalytics = NO;
    usesCoreData = NO;
    usesSlidingMenu = YES;
    return self;
}
-(void) enableZeroPushNotificationWithKey:(NSString*)key andDelegate:(id)delegate
{
    [ZeroPush engageWithAPIKey:key delegate:delegate];
    
    //now ask the user if they want to recieve push notifications. You can place this in another part of your app.
    [[ZeroPush shared] registerForRemoteNotifications];
    usesPushNotifications = YES;
}

-(void) enableCoreData
{
    usesCoreData = YES;
}
-(void) enableSlidingMenu
{
    usesSlidingMenu = YES;
}

-(void) enableGoogleAnalyticsWithKey:(NSString*)key
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:key];
    
    usesGoogleAnalytics = YES;
}

-(void)zeroPushNotificationSuccess:(NSData*)data
{
    // Call the convenience method registerDeviceToken, this helps us track device tokens for you
    [[ZeroPush shared] registerDeviceToken:data];
    
    // This would be a good time to save the token and associate it with a user that you want to notify later.
   // NSString *tokenString = [ZeroPush deviceTokenFromData:data];
}

-(void)zeroPushNotificationFail:(NSError *)error
{
    NSLog(@"Error registering for push notifications %@", [error description]);
}
@end
