//
//  AlbumDetailViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/26/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Album.h"
#import "Albums.h"
#import "AudioPlayback.h"
#import "DatabaseInterface.h"

@interface AlbumDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableOrderedSet *albumInternalIDs;

@end
