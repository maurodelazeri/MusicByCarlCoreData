//
//  AllAlbumsViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/28/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Albums.h"
#import "DatabaseInterface.h"
#import "FetchedTableViewController.h"

@interface AllAlbumsViewController : FetchedTableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL instrumentalAlbumsFlag;

@property (strong, nonatomic) Albums *albumsPtr;
@property (strong, nonatomic) NSArray *sectionIndexTitles; // of NSString
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString

@end
