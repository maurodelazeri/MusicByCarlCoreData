//
//  UserPreferencesArchive.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/19/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "UserPreferences.h"

@interface UserPreferencesArchive : NSManagedObject

@property (nonatomic, retain) NSData * archivedInstrumentalAlbums;
@property (nonatomic, retain) NSNumber * archivedShuffleFlag;
@property (nonatomic, retain) NSNumber * archivedVolumeLevel;

+ (void)archiveUserPreferences: (UserPreferences *)userPreferences;
+ (NSMutableDictionary *)unarchiveUserPreferences;

@end
