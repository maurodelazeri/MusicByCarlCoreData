//
//  GlobalVars.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/18/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject <NSCoding>

@property (nonatomic) NSNumber *currentAlbum;
@property (nonatomic) NSNumber *currentSong;

// Singleton pointer given to other classes who access the GlobalVars class
+ (GlobalVars *)sharedGlobalVars;

- (void)archiveData;

@end
