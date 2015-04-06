//
//  AllGenresViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/8/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Genres.h"

@interface AllGenresViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) Genres *genresPtr;

@property (strong, nonatomic) NSArray *sectionIndexTitles; // of NSString
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
