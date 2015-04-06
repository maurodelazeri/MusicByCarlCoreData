//
//  DatabaseManager.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 6/13/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "DatabaseManager.h"

#import "Utilities.h"
#import "Logger.h"

@interface DatabaseManager()
@property (strong, nonatomic, readwrite) NSOperationQueue *operationQueue;
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *storeCoordinator;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainContext;     // main managedObjectContext, which is tied to the UI
@property (strong, nonatomic, readwrite) NSURL *modelURL;
@property (strong, nonatomic, readwrite) NSURL *storeURL;
@property (strong, nonatomic, readwrite) NSManagedObjectModel *model;
@end

@implementation DatabaseManager

@synthesize operationQueue = _operationQueue;
@synthesize storeCoordinator = _storeCoordinator;
@synthesize mainContext = _mainContext;
@synthesize modelURL = _modelURL;
@synthesize storeURL = _storeURL;
@synthesize model = _model;
@synthesize databaseBuildInProgress = _databaseBuildInProgress;

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _operationQueue;
}

- (NSURL *)modelURL
{
    if (!_modelURL)
    {
        _modelURL = [[NSBundle mainBundle] URLForResource:@"MusicByCarl" withExtension:@"momd"];
    }
    
    return _modelURL;
}

- (NSURL *)storeURL
{
    if (!_storeURL)
    {
        _storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MusicByCarl.sqlite"];
    }
    
    return _storeURL;
}

- (NSManagedObjectModel *)model
{
    if (!_model)
    {
        _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    }
    
    return _model;
}

- (NSPersistentStoreCoordinator *)storeCoordinator
{
    if (!_storeCoordinator)
    {
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];

        NSError *error;
        
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES
                                  };
        
        [_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil URL:self.storeURL options:options error:&error];
        if (error.code != 0)
        {
            [Logger writeToLogFile:[NSString stringWithFormat:@"Error adding persistent store to store coordinator: %ld, %@", (long)error.code, error.description]];
        }
    }
    
    return _storeCoordinator;
}

- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext)
    {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [_mainContext setPersistentStoreCoordinator:self.storeCoordinator];
    }
    
    return _mainContext;
}

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (DatabaseManager *)sharedDatabaseManager
{
    static dispatch_once_t pred = 0;
    __strong static DatabaseManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[DatabaseManager alloc] init];
    });
    return _sharedObject;
}

- (NSManagedObjectContext *)returnMainManagedObjectContext
{
    return self.mainContext;
}

- (NSPersistentStoreCoordinator *)returnPersistentStoreCoordinator
{
    return self.storeCoordinator;
}

- (void)initModelAndStore
{
    // Create NSManagedObjectModel and NSPersistentStoreCoordinator
    if (self.model)
    {
        if (self.storeCoordinator)
        {
            if (self.mainContext)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
            }
            else
            {
                [Logger writeToLogFile:@"Error creating main context"];
            }
        }
        else
        {
            [Logger writeToLogFile:@"Error creating persistent store coordinator"];
        }
    }
    else
    {
        [Logger writeToLogFile:@"Error creating managed object model"];
    }
}

- (void)contextSaved: (NSNotification *)notification
{
    void (^mergeChanges) (void) = ^
    {
        [_mainContext mergeChangesFromContextDidSaveNotification:notification];
    };
    
    if ([NSThread isMainThread])
    {
        mergeChanges();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), mergeChanges);
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
