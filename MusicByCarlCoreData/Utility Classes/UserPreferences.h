//
//  UserPreferences.h
//  MusicByCarl
//
//  Created by CarlSmith on 3/24/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferences : NSObject <NSCoding>

// Singleton pointer given to other classes who access the UserPreferences class
+ (UserPreferences *)sharedUserPreferences;

- (void)loadUserPreferences;

@property (nonatomic, readonly) BOOL shuffleFlag;
@property (nonatomic, readonly) float volumeLevel;
@property (strong, nonatomic, readonly) NSArray *instrumentalAlbums;

- (BOOL)findInstrumentalAlbumWithTitle: (NSString *)title andArtist: (NSString *)artist;

- (void)newShuffleFlagValue: (BOOL)newValue;
- (void)newVolumeLevel: (float)newValue;

- (void)archiveData;

@end
