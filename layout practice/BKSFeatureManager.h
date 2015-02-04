//
//  BKS Feature Manager.h
//  BKS base project
//
//  Created by James Coughlan on 02/02/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKSFeatureManager : NSObject
{
    BOOL usesPushNotifications;
    BOOL usesCoreData;
    BOOL usesGoogleAnalytics;
    BOOL usesSlidingMenu;
}
+ (BKSFeatureManager*)sharedManager;
-(id)init;

-(void) enableZeroPushNotificationWithKey:(NSString*)key andDelegate:(id)delegate;
-(void) enableCoreData;
-(void) enableSlidingMenu;
-(void) enableGoogleAnalyticsWithKey:(NSString*)key withLogging:(BOOL)logging;
-(void) enableRegularLogging;
-(void) enableFileLogging;

-(void)zeroPushNotificationSuccess:(NSData*)data;
-(void)zeroPushNotificationFail:(NSError *)error;
@end
