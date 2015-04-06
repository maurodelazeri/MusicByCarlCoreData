//
//  AlbumTrackDetailCell.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 8/26/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTrackDetailCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *trackNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackArtistLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackSingleArtistTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackDurationLabel;
@end
