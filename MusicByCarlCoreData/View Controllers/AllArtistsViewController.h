//
//  AllArtistsViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/30/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Artists.h"
#import "Genre.h"

@interface AllArtistsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Artists *artistsPtr;
@property (strong, nonatomic) NSArray *sectionIndexTitles; // of NSString
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *showAllButton;

- (IBAction)showAllButtonPressed:(id)sender;

@end
