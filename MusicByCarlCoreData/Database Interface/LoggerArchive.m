//
//  LoggerArchive.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "LoggerArchive.h"
#import "DatabaseInterface.h"

@implementation LoggerArchive

@dynamic archivedLogMessages;

+ (void)archiveLogMessages: (NSMutableArray *)logMessages {
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    [databaseInterfacePtr deleteAllObjectsWithEntityName:@"LoggerArchive"];
    LoggerArchive *loggerArchive = (LoggerArchive *)[databaseInterfacePtr newManagedObjectOfType:@"LoggerArchive"];
    NSData *logMessageData = [NSKeyedArchiver archivedDataWithRootObject:logMessages];
    loggerArchive.archivedLogMessages = logMessageData;
    [databaseInterfacePtr saveContext];
}

+ (NSMutableArray *)unarchiveLogMessages {
    NSMutableArray *returnValue = nil;
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *loggerArchiveArray = [databaseInterfacePtr entitiesOfType:@"LoggerArchive" withFetchRequestChangeBlock:nil];
    if (loggerArchiveArray != nil && loggerArchiveArray.count == 1) {
        LoggerArchive *loggerArchive = [loggerArchiveArray objectAtIndex:0];
        returnValue = [NSKeyedUnarchiver unarchiveObjectWithData:loggerArchive.archivedLogMessages];
        [databaseInterfacePtr deleteAllObjectsWithEntityName:@"LoggerArchive"];
        [databaseInterfacePtr saveContext];
    }
    
    return returnValue;
}

@end
