//
//  DatabaseViewController.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 7/27/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import "DatabaseViewController.h"
#import "DatabaseInterface.h"
#import "DatabaseManager.h"

#import "Artists.h"
#import "Albums.h"
#import "Playlists.h"
#import "Songs.h"
#import "Genres.h"
#import "SongCell.h"

#import "Logger.h"
#import "Utilities.h"

@interface DatabaseViewController ()
{
    DatabaseManager *databaseManagerPtr;
    Artists *artistsPtr;
    Albums *albumsPtr;
    Playlists *playlistsPtr;
    Songs *songsPtr;
    Genres *genresPtr;
    NSMutableArray *lastPlayedTimes;
    UIActivityIndicatorView *databaseScreenSpinner;
    UIAlertView *albumAdditionAlert;
}
@end

@implementation DatabaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    databaseManagerPtr = [DatabaseManager sharedDatabaseManager];
    
    artistsPtr = [Artists sharedArtists];
    albumsPtr = [Albums sharedAlbums];
    playlistsPtr = [Playlists sharedPlaylists];
    songsPtr = [Songs sharedSongs];
    genresPtr = [Genres sharedGenres];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGSize scrollViewSize = self.scrollView.contentSize;
    scrollViewSize.height = self.progressView.frame.origin.y + self.progressView.frame.size.height + 10;
    self.scrollView.contentSize = scrollViewSize;

    [self.progressView setProgress:0.0f];
    
    [self registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector:@selector(handle_ProgressNotification:)
                               name:@"MusicByCarlCoreData.databaseProgressNotification"
                             object:nil];
}

- (void) deregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name:@"MusicByCarlCoreData.databaseProgressNotification"
                                                  object:nil];
}

- (void) updateProgress: (NSDictionary *)notificationUserInfo
{
    NSNumber *progressFraction = [notificationUserInfo objectForKey:@"progressFraction"];
    NSString *operationType = [notificationUserInfo objectForKey:@"operationType"];
    
    if (progressFraction.floatValue == 1.0f)
    {
        [self.progressView setProgress:0.0f];
        [self showBuildCompletionAlert:operationType];
        
        if ([operationType isEqualToString:@"Genre"])
        {
            self.buildAllButton.tintColor = [UIColor greenColor];
            self.progressViewLabel.text = @"Build All Completed";
        }
    }
    else
    {
        [self.progressView setProgress:[progressFraction floatValue]];
    }
}

- (void)cancelAlert: (id)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)showBuildCompletionAlert: (NSString *)operationType
{
    BOOL buildAllCompleted = NO;
    
    self.progressViewLabel.text = [NSString stringWithFormat:@"%@ List Build Completed", operationType];
    
    if ([operationType isEqualToString:@"Song"])
    {
        self.buildSongListLabel.textColor = [UIColor greenColor];
    }
    else
    {
        if ([operationType isEqualToString:@"Album"])
        {
            self.buildAlbumListLabel.textColor = [UIColor greenColor];
        }
        else
        {
            if ([operationType isEqualToString:@"Artist"])
            {
                self.buildArtistListLabel.textColor = [UIColor greenColor];
            }
            else
            {
                if ([operationType isEqualToString:@"Playlist"])
                {
                    self.buildPlaylistListLabel.textColor = [UIColor greenColor];
                }
                else
                {
                    if ([operationType isEqualToString:@"Genre"])
                    {
                        self.buildGenreListLabel.textColor = [UIColor greenColor];
                        buildAllCompleted = YES;
                    }
                }
            }
        }
    }

    UIAlertView *alert;
    if (buildAllCompleted) {
        alert = [Utilities showNoButtonAlert:@"Progress Alert" message:@"Build All Completed"];
    }
    else {
        alert = [Utilities showNoButtonAlert:@"Progress Alert" message:[NSString stringWithFormat:@"%@ List Built", operationType]];
    }
    [self performSelector:@selector(cancelAlert:) withObject:alert afterDelay:2.0f];
}

- (void) handle_ProgressNotification: (NSNotification *)notification
{
    NSDictionary *notificationUserInfo = notification.userInfo;
    
    if (notificationUserInfo)
    {
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:notificationUserInfo waitUntilDone:NO];
    }
}

- (void)deletePhase: (NSString *)entityName withDatabasePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.progressViewLabel.text = [NSString stringWithFormat:@"Deleting %@s", entityName];
        self.progressView.alpha = 0.0f;
    });
    
    [databaseInterfacePtr deleteAllObjectsWithEntityName:entityName];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.progressViewLabel.text = [NSString stringWithFormat:@"%@ Addition Progress", entityName];
        self.progressView.alpha = 1.0f;
    });
}

- (IBAction)buildAllButtonPressed:(id)sender
{
    self.buildAllButton.tintColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
    
    [databaseManagerPtr.operationQueue addOperationWithBlock: ^(void)
    {
        databaseManagerPtr.databaseBuildInProgress = YES;
        DatabaseInterface *databaseInterfacePtr = [[DatabaseInterface alloc] init];
        
        [songsPtr fillSongsWithNonzeroLastPlayedTimesWithDatabasePtr:databaseInterfacePtr];
        
        [self deletePhase:@"Song" withDatabasePtr:databaseInterfacePtr];
        [self deletePhase:@"Album" withDatabasePtr:databaseInterfacePtr];
        [self deletePhase:@"Artist" withDatabasePtr:databaseInterfacePtr];
        [self deletePhase:@"Playlist" withDatabasePtr:databaseInterfacePtr];
        [self deletePhase:@"Genre" withDatabasePtr:databaseInterfacePtr];
        
        [self buildSongListWithDatabaseInterfacePtr:databaseInterfacePtr];
        [self buildAlbumListWithDatabaseInterfacePtr:databaseInterfacePtr];
        [self buildArtistListWithDatabaseInterfacePtr:databaseInterfacePtr];
        [self buildPlaylistListWithDatabaseInterfacePtr:databaseInterfacePtr];
        [self buildGenreListWithDatabaseInterfacePtr:databaseInterfacePtr];
        databaseManagerPtr.databaseBuildInProgress = NO;
    }];
}

- (void)buildSongListWithDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.textColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        self.progressViewLabel.text = [NSString stringWithFormat:@"Song Addition Progress"];
        self.progressView.alpha = 1.0f;
    });
    
    if (databaseInterfacePtr == nil)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    [songsPtr fillDatabaseSongsFromItunesLibrary:YES withDatabasePtr:databaseInterfacePtr];
    
    [songsPtr restoreLastPlayedTimesWithDatabasePtr:databaseInterfacePtr];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.text = @"Song List Built";
    });
}

- (void)buildAlbumListWithDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildAlbumListLabel.textColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        self.progressViewLabel.text = [NSString stringWithFormat:@"Album Addition Progress"];
        self.progressView.alpha = 1.0f;
    });
    
    if (databaseInterfacePtr == nil)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    NSUInteger beforeAlbumCount = [databaseInterfacePtr countOfEntitiesOfType:@"Album" withFetchRequestChangeBlock:nil];
    
    [albumsPtr fillDatabaseAlbumsFromItunesLibrary:YES withDatabasePtr:databaseInterfacePtr];
    
    NSUInteger afterAlbumCount = [databaseInterfacePtr countOfEntitiesOfType:@"Album" withFetchRequestChangeBlock:nil];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.text = @"Album List Built";
    });
    
    if (afterAlbumCount > beforeAlbumCount)
    {
        [self performSelectorOnMainThread:@selector(albumAdditionReminder) withObject:nil waitUntilDone:NO];
    }
}

- (void)albumAdditionReminder
{
    albumAdditionAlert = [Utilities showNoButtonAlert:@"Albums" message:@"Albums added; update instumentalAlbums in defaultValues.plist if necessary"];
    [self performSelector:@selector(cancelAlert:) withObject:albumAdditionAlert afterDelay:5.0f];
}

- (void)buildArtistListWithDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildArtistListLabel.textColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        self.progressViewLabel.text = [NSString stringWithFormat:@"Artist Addition Progress"];
        self.progressView.alpha = 1.0f;
    });
    
    if (databaseInterfacePtr == nil)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    [artistsPtr fillDatabaseArtistsFromItunesLibrary:YES withDatabasePtr:databaseInterfacePtr];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.text = @"Artist List Built";
    });
}

- (void)buildPlaylistListWithDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildPlaylistListLabel.textColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        self.progressViewLabel.text = [NSString stringWithFormat:@"Playlist Addition Progress"];
        self.progressView.alpha = 1.0f;
    });
    
    if (databaseInterfacePtr == nil)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    [playlistsPtr fillDatabasePlaylistsFromItunesLibrary:YES withDatabasePtr:databaseInterfacePtr];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.text = @"Playlists List Built";
    });
}

- (void)buildGenreListWithDatabaseInterfacePtr: (DatabaseInterface *)databaseInterfacePtr
{
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildGenreListLabel.textColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        self.progressViewLabel.text = [NSString stringWithFormat:@"Genre Addition Progress"];
        self.progressView.alpha = 1.0f;
    });
    
    if (databaseInterfacePtr == nil)
    {
        databaseInterfacePtr = [[DatabaseInterface alloc] init];
    }
    
    [genresPtr fillDatabaseGenresFromItunesLibrary:YES withDatabasePtr:databaseInterfacePtr];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        self.buildSongListLabel.text = @"Genre List Built";
    });
}

@end
