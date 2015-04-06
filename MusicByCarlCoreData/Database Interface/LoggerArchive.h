//
//  LoggerArchive.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LoggerArchive : NSManagedObject

@property (nonatomic, retain) NSData * archivedLogMessages;

+ (void)archiveLogMessages: (NSMutableArray *)logMessages;
+ (NSMutableArray *)unarchiveLogMessages;

@end
