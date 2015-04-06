//
//  FetchedTableViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/17/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FetchedTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSString *searchBarText;
@property (nonatomic) BOOL searchBarShown;

- (id)initWithTableView: (UITableView *)tableView;
- (void)assignFetchedResultsController: (NSFetchedResultsController *)fetchedResultsController;

- (void)showHideSearchBar;
- (void)clearSearchBarText;

@end
