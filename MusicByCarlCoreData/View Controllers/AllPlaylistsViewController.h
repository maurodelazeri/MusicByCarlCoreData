//
//  AllPlaylistsViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/3/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllPlaylistsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
