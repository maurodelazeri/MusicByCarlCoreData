//
//  DatabaseInterface.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "AppDelegate.h"

#import "DatabaseInterface.h"
#import "DatabaseManager.h"

#import "Utilities.h"
#import "Logger.h"

@interface DatabaseInterface ()
{
    NSManagedObjectContext *_context;  // private managedObjectContext whichs runs in a background thread,
                                              // so that writes to the disk don't block the UI
}
@end

@implementation DatabaseInterface

- (id)init
{
    self = [super init];
    
    if (self)
    {
        DatabaseManager *databaseManagerPtr = [DatabaseManager sharedDatabaseManager];
        
        if ([NSThread isMainThread])
        {
            _context = [databaseManagerPtr returnMainManagedObjectContext];
        }
        else
        {
            _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
            [_context setPersistentStoreCoordinator:[databaseManagerPtr returnPersistentStoreCoordinator]];
        }
    }
    
    return self;
}

- (NSManagedObject *)newManagedObjectOfType:(NSString *)managedObjectType
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:managedObjectType
                                                         inManagedObjectContext:_context];
    if (entityDescription == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    Class class = NSClassFromString(managedObjectType);
    if (class == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"ClassType does not exist"
                                     userInfo:nil];
    
    return [[class alloc] initWithEntity:entityDescription
          insertIntoManagedObjectContext:_context];
}

- (NSArray *)entitiesOfType:(NSString *)type withFetchRequestChangeBlock:(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:type];
    if (fetchRequest == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    if (fetchRequestChangeBlock != nil)
        fetchRequest = fetchRequestChangeBlock(fetchRequest);
    
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSError *error = nil;
    NSArray *result = nil;
    result = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error while fetching results: %@", error]];
        return nil;
    }
    
    return result;
}

- (NSUInteger)countOfEntitiesOfType:(NSString *)type withFetchRequestChangeBlock:(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:type];
    if (fetchRequest == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    if (fetchRequestChangeBlock != nil)
        fetchRequest = fetchRequestChangeBlock(fetchRequest);
    
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSError *error = nil;
    NSInteger result = 0;
    result = [_context countForFetchRequest:fetchRequest error:&error];
    
    if (error != nil)
    {
        [Logger writeToLogFile:[NSString stringWithFormat:@"Error while fetching results: %@", error]];
        return 0;
    }
    
    return result;
}

- (void) deleteAllObjectsWithEntityName: (NSString *)entityDescription
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items)
    {
        [_context deleteObject:managedObject];
    }
    
    [self saveContext];
}

- (void) deleteAllObjectsWithEntityName: (NSString *)entityDescription withCompletionBlock:(void (^)(void))completionBlock
{
    DatabaseManager *databaseManagerPtr = [DatabaseManager sharedDatabaseManager];
    
    [databaseManagerPtr.operationQueue addOperationWithBlock: ^(void)
    {
        [self deleteAllObjectsWithEntityName:entityDescription];
        completionBlock();
    }];
}

- (NSFetchedResultsController *)createFetchedResultsController: (NSString *)entityName withKeyPath: (NSString *)keyPath andSecondarySortKey: (NSString *)secondarySortKey
{
    NSFetchedResultsController *fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];

    // Configure the request's entity, and optionally its predicate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:YES];

    NSArray *sortDescriptors;
    if (secondarySortKey != nil)
    {
        NSSortDescriptor *secondarySortDescriptor = [[NSSortDescriptor alloc] initWithKey:secondarySortKey ascending:YES];
        sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, secondarySortDescriptor, nil];
    }
    else
    {
        sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    }
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    [fetchRequest setFetchBatchSize:30];

    fetchRequest.returnsObjectsAsFaults = NO;

    fetchedResultsController = [[NSFetchedResultsController alloc]
                             initWithFetchRequest:fetchRequest
                             managedObjectContext:_context
                             sectionNameKeyPath:keyPath
                             cacheName:nil];

    NSError *error;
    if (![fetchedResultsController performFetch:&error])
    {
     [Logger writeToLogFile:[NSString stringWithFormat:@"Error initializing songs fetchedResultsController: %@", error]];
    }
    
    return fetchedResultsController;
}

- (NSFetchedResultsController *)createFetchedResultsController: (NSString *)entityName withKeyPath: (NSString *)keyPath secondarySortKey: (NSString *)secondarySortKey andFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock;
{
    NSFetchedResultsController *fetchedResultsController;
    
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
     
     if (fetchRequestChangeBlock != nil)
         fetchRequest = fetchRequestChangeBlock(fetchRequest);
     
     // Configure the request's entity, and optionally its predicate.
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:YES];

     NSArray *sortDescriptors;
     if (secondarySortKey != nil)
     {
         NSSortDescriptor *secondarySortDescriptor = [[NSSortDescriptor alloc] initWithKey:secondarySortKey ascending:YES];
         sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, secondarySortDescriptor, nil];
     }
     else
     {
         sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
     }

     [fetchRequest setSortDescriptors:sortDescriptors];
     
     [fetchRequest setFetchBatchSize:30];
     
     fetchRequest.returnsObjectsAsFaults = NO;
    
     fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:_context
                                 sectionNameKeyPath:keyPath
                                 cacheName:nil];
     
     NSError *error;
     if (![fetchedResultsController performFetch:&error])
     {
         [Logger writeToLogFile:[NSString stringWithFormat:@"Error initializing songs fetchedResultsController: %@", error]];
     }
    
    return fetchedResultsController;
}

#pragma mark - Core Data stack

- (void)saveContext
{
    if (_context != nil)
    {
         NSError *error;
         
         if (![_context save:&error])
         {
             [Logger writeToLogFile:[NSString stringWithFormat:@"Error saving main context: %@", error]];
         }
    }
}

@end
