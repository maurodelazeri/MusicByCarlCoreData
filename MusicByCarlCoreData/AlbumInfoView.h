//
//  AlbumInfoView.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/3/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumInfoView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *albumArtworkImageView;
@property (strong, nonatomic) IBOutlet UILabel *albumArtistLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumReleaseYearLabel;

@end
