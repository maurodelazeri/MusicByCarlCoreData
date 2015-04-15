//
//  AllSongsViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioPlayback.h"
#import "FetchedTableViewController.h"

@interface AllSongsViewController : FetchedTableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) AudioPlayback *audioPlaybackPtr;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *sectionIndexTitles; // of NSString
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString

@end
