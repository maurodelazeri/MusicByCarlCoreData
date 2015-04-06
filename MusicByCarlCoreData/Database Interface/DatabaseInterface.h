//
//  DatabaseInterface.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseInterface : NSObject

/**
 * Creates a new managedObject of the given type and keeps
 * threading into account. If called from the mainThread
 * it uses the parentContext. If called from a background thread
 * it uses the childContext. Here the assumption is made that you
 * only perform coredata calls using the performBlock: functions.
 * If not, another background thread may be used which is not
 * tied to the child context. Therefore, if you have to perform
 * a large operation on the background, always use performBlock:
 * on the childContext
 *
 * @param type Entity of the managedObject to create
 * @result Newly created managedObject
 */
- (NSManagedObject *)newManagedObjectOfType:(NSString *)managedObjectType;

/**
 * Performs a synchronous fetchRequest. Selects the correct
 * managedObjectContext using the same technique as described in
 * the newManagedObjectOfType: function
 *
 * @param type Entity to fetch
 * @param fetchRequestChangeBlock Here you can make modifications to the fetchRequest (e.g. adding predicates, setting batch sizes, etc)
 * @result Result of the fetchRequest
 */
- (NSArray *)entitiesOfType:(NSString *)type withFetchRequestChangeBlock:(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock;

- (NSUInteger)countOfEntitiesOfType:(NSString *)type withFetchRequestChangeBlock:(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock;

/**
 * Does the same as entitiesOfType:withFetchRequestChangeBlock: but also
 * contains a completionBlock because the request is performed asynchronously.
 *
 * @param type Entity to fetch
 * @param fetchRequestChangeBlock Here you can make modifications to the fetchRequest (e.g. adding predicates, setting batch sizes, etc)
 * @param completionBlock Block which is executed after a result has been obtained.
 */
//- (void)entitiesOfType:(NSString *)type withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock withCompletionBlock:(void (^)(NSArray *))completionBlock;

/**
 * Makes sure that the array of given managedObjects
 * is tied to the parentManagedObjectContext
 *
 * @param managedObjects Array of NSManagedObjects to convert the the parentContext
 * @result Converted objects
 */
//- (NSArray *)convertManagedObjectsToMainContext:(NSArray *)managedObjects;

- (NSFetchedResultsController *)createFetchedResultsController: (NSString *)entityName withKeyPath: (NSString *)keyPath andSecondarySortKey: (NSString *)secondarySortKey;
- (NSFetchedResultsController *)createFetchedResultsController: (NSString *)entityName withKeyPath: (NSString *)keyPath secondarySortKey: (NSString *)secondarySortKey andFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock;

- (void)saveContext;
//- (NSManagedObjectContext *)returnAppropriateManagedObjectContext;

- (void) deleteAllObjectsWithEntityName: (NSString *)entityDescription withCompletionBlock:(void (^)(void))completionBlock;
- (void) deleteAllObjectsWithEntityName: (NSString *)entityDescription;

@end
