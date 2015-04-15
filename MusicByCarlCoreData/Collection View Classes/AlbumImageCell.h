//
//  AlbumImageCell.h
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 9/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkImage;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkReflectionImage;
@end
