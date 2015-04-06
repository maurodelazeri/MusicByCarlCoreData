//
//  CSMediaQuerySection.h
//  MusicByCarl
//
//  Created by CarlSmith on 3/30/13.
//  Copyright (c) 2013 CarlSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSMediaQuerySection : NSObject

@property (nonatomic, assign, readwrite) NSRange range;

@property (nonatomic, copy, readwrite) NSString *title;

@end
