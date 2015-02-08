//
//  GSCoreDataManager.h
//  GSCoreData
//
//  Created by James Coughlan on 26/01/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAThreadSafeContext.h"
#import "IAThreadSafeManagedObject.h"
//void NSLog(NSString* string1,...);

@interface BKSCoreDataManager : NSObject
@property (readonly, strong, nonatomic) IAThreadSafeContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


-(NSArray*)fetchObjectsWithClass:(Class)class;

-(IAThreadSafeManagedObject*)fetchSingleObjectWithID:(id)identifier andClass:(Class)class;

-(void) deleteObject: (IAThreadSafeManagedObject*)object;
-(int) deleteAllCoreDataObjects;
+ (BKSCoreDataManager*)sharedManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
