//
//  Itoast.h
//  MusicByCarlCoreData
//
//  Created by Carleton Smith on 1/8/14.
//  Copyright (c) 2014 Bulletin Net Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IToast : NSObject

@property (strong, nonatomic) void (^completionHandler)(void);

- (void)showToast: (NSString *)alertTitle withMessage: (NSString *)alertMessage forDuration: (NSTimeInterval)duration withCompletionHandler: (void(^)(void))completionHandler;

@end
