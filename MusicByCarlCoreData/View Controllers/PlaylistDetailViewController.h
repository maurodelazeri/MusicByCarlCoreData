//
//  PlaylistDetailViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/5/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Playlist.h"
#import "Playlists.h"
#import "FetchedTableViewController.h"

@interface PlaylistDetailViewController : FetchedTableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Playlists *playlistsPtr;

@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) NSNumber *playlistInternalID;

@property (strong, nonatomic) NSArray *sectionIndexTitles; // of NSString
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *songCountLabel;

@end
