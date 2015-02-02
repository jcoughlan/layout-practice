//
//  AppDelegate.h
//  layout practice
//
//  Created by James Coughlan on 31/01/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <ZeroPush.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, ZeroPushDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

