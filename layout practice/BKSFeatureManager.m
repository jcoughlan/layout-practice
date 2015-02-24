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
#import "DDSLogger.h"
#import "BKSCoreDataManager.h"

#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

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
    //this will initialize everthing, important to do on main thread
    [BKSCoreDataManager sharedManager];
}
-(void) enableSlidingMenu
{
    usesSlidingMenu = YES;
}

-(void) enableGoogleAnalyticsWithKey:(NSString*)key withLogging:(BOOL)logging
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    if(logging)
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    else
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
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
    DDLogError(@"Error registering for push notifications %@", [error description]);
}

-(void)enableRegularLogging
{
    setenv("XcodeColors", "YES", 0);

    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //    // Convert from this:
    //    NSLog(@"Broken sprocket detected!");
    //    NSLog(@"User selected file:%@ withSize:%u", filePath, fileSize);
    //
    //    // To this:
    //    DDLogError(@"Broken sprocket detected!");
    //    DDLogVerbose(@"User selected file:%@ withSize:%u", filePath, fileSize);
    //   DDLogError
    // DDLogWarn
    // DDLogInfo
    // DDLogDebug
    // DDLogVerbose
}

-(void)enableFileLogging
{
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 ; // 1 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
    
    [DDLog addLogger:fileLogger];
}
@end