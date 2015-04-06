//
//  AlbumInfoView.m
//  MusicByCarlCoreData
//
//  Created by CarlSmith on 2/3/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

#import "AlbumInfoView.h"

@implementation AlbumInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSArray *subviews = [[NSBundle mainBundle] loadNibNamed:@"AlbumInfoView" owner:self options:nil];
        [self addSubview:[subviews objectAtIndex:0]];
    }
    return self;
}

@end
