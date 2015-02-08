//
//  GSCoreDataManager.m
//  GSCoreData
//
//  Created by James Coughlan on 26/01/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import "BKSCoreDataManager.h"
@implementation BKSCoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (BKSCoreDataManager*)sharedManager {
    static BKSCoreDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        [sharedMyManager managedObjectContext];
        [sharedMyManager managedObjectModel];
        [sharedMyManager persistentStoreCoordinator];
        
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            [sharedMyManager saveContext];
        });
    });
    return sharedMyManager;
}



-(void) deleteObject: (IAThreadSafeManagedObject*)object
{
    if(object)
        [self.managedObjectContext deleteObject:object];
}

-(int) deleteAllCoreDataObjects
{
    NSError* error;
    if([NSThread isMainThread]) {
        for ( NSPersistentStore *store in [_persistentStoreCoordinator persistentStores])
        {
            
            
            if (store) {
                if (![_persistentStoreCoordinator removePersistentStore:store error:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                
                // Delete file
                if ([[NSFileManager defaultManager] fileExistsAtPath:store.URL.path]) {
                    if (![[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            }
        }
        // Delete the reference to non-existing store
        _persistentStoreCoordinator = nil;
        _managedObjectContext = nil;
        _managedObjectModel = nil;
        [self persistentStoreCoordinator];
        [self managedObjectContext];
        [self managedObjectModel];

    }
    else
    {
        dispatch_async(
                       dispatch_get_main_queue(), ^
                       {
                           [self deleteAllCoreDataObjects];
                           
                       });
    }
    //    NSMutableArray* entities = [[NSMutableArray alloc] initWithObjects:[GingersnapActivity class], [GingersnapActivityTemplate class], [GingersnapAvatar class],[GingersnapChild class], [GingersnapConnection class], [GingersnapEvent class], [GingersnapImage class], [GingersnapParent class], [GingersnapRelationship class], [GingersnapShare class], [GingersnapUser class],  nil];
    //    int counter = 0;
    //    for(Class entity in entities)
    //    {
    //        NSArray* objects = [self fetchObjectsWithClass:entity];
    //        for (IAThreadSafeManagedObject* object in objects)
    //        {
    //            [self deleteObject:object];
    //            counter++;
    //        }
    //    }
    //    NSLog(@"Deleted %d objects from core data", counter);
    //    return counter;
    return 0;
}

-(NSArray*)fetchObjectsWithClass:(Class)class
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest  error:nil];
    
    return results;
}

-(IAThreadSafeManagedObject*)fetchSingleObjectWithID:(id)identifier andClass:(Class)class
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
    [fetchRequest setPredicate:predicate];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest  error:nil];
    
    assert([results count] <2);
    
    return [results count] ? [results objectAtIndex:0] : nil;
}
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "fp.GSCoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if ( _managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BKSCoreDataModel" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return _managedObjectModel;
}

//*****CoreData Specific*****\\//*****initialises persistentStore as sqllite object*****
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BKSCoreDataModel.sqlite"];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeURL options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}



- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[IAThreadSafeContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@ %@ ", error, [error userInfo]);
            abort();
        }
    }
    // dispatch_get_main_queue();
    //[GingersnapSession sharedManager].coreDataQueue
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self saveContext];
    });
    
    
}
@end
