//
//  UserPreferencesArchive.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "UserPreferencesArchive.h"
#import "DatabaseInterface.h"
#import "Logger.h"

@implementation UserPreferencesArchive

@dynamic archivedInstrumentalAlbums;
@dynamic archivedShuffleFlag;
@dynamic archivedVolumeLevel;

- (NSString *)description {
    NSString *returnValue = [NSString stringWithFormat:@"\narchivedShuffleFlag = %d", [self.archivedShuffleFlag boolValue]];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedVolumeLevel = %.2f", [self.archivedVolumeLevel floatValue]];
    NSMutableArray *archivedInstrumentalAlbums = [NSKeyedUnarchiver unarchiveObjectWithData:self.archivedInstrumentalAlbums];
    returnValue = [returnValue stringByAppendingFormat:@"\narchivedInstrumentalAlbums.count = %lu", (unsigned long)archivedInstrumentalAlbums.count];
    
    return returnValue;
}

+ (void)archiveUserPreferences: (UserPreferences *)userPreferences {
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    [databaseInterfacePtr deleteAllObjectsWithEntityName:@"UserPreferencesArchive"];
    UserPreferencesArchive *userPreferencesArchive = (UserPreferencesArchive *)[databaseInterfacePtr newManagedObjectOfType:@"UserPreferencesArchive"];
    userPreferencesArchive.archivedShuffleFlag = [NSNumber numberWithBool:userPreferences.shuffleFlag];
    userPreferencesArchive.archivedVolumeLevel = [NSNumber numberWithFloat:userPreferences.volumeLevel];
    NSData *archivedInstrumentalAlbums = [NSKeyedArchiver archivedDataWithRootObject:userPreferences.instrumentalAlbums];
    userPreferencesArchive.archivedInstrumentalAlbums = archivedInstrumentalAlbums;
    [databaseInterfacePtr saveContext];
}

+ (NSMutableDictionary *)unarchiveUserPreferences {
    NSMutableDictionary *returnValue = nil;
    DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
    NSArray *userPreferencesArchiveArray = [databaseInterfacePtr entitiesOfType:@"UserPreferencesArchive" withFetchRequestChangeBlock:nil];
    
    if (userPreferencesArchiveArray != nil && userPreferencesArchiveArray.count == 1) {
        UserPreferencesArchive *userPreferencesArchive = [userPreferencesArchiveArray objectAtIndex:0];
        returnValue = [[NSMutableDictionary alloc] init];
        [returnValue setObject:userPreferencesArchive.archivedShuffleFlag forKey:@"archivedShuffleFlag"];
        [returnValue setObject:userPreferencesArchive.archivedVolumeLevel forKey:@"archivedVolumeLevel"];
        [returnValue setObject:userPreferencesArchive.archivedInstrumentalAlbums forKey:@"archivedInstrumentalAlbums"];
    }
    
    return returnValue;
}

@end
