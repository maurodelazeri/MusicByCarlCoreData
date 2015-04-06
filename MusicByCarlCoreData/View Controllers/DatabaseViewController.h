//
//  DatabaseViewController.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatabaseViewController : UIViewController

- (IBAction)buildAllButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *buildAllButton;
@property (weak, nonatomic) IBOutlet UILabel *buildSongListLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildAlbumListLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildArtistListLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildPlaylistListLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildGenreListLabel;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *progressViewLabel;

@end
