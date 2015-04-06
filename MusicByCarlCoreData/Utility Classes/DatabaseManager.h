//
//  DatabaseManager.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/13/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseManager : NSObject // <NSCoding>

@property (strong, nonatomic, readonly) NSOperationQueue *operationQueue;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *storeCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;     // main managedObjectContext, which is tied to the UI
@property (strong, nonatomic, readonly) NSURL *modelURL;
@property (strong, nonatomic, readonly) NSURL *storeURL;
@property (strong, nonatomic, readonly) NSManagedObjectModel *model;

// Singleton pointer given to other classes who access the DatabaseInterface class
+ (DatabaseManager *)sharedDatabaseManager;

- (void)initModelAndStore;

- (NSManagedObjectContext *)returnMainManagedObjectContext;
- (NSPersistentStoreCoordinator *)returnPersistentStoreCoordinator;

@property (nonatomic) BOOL databaseBuildInProgress;

@end
