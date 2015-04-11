//
//  Logger.h
//  DealSiftr
//
//  Created by Carleton Smith on 11/5/13.
//  Copyright (c) 2013 Carleton Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *logMessages;

+ (Logger *)sharedLogger;

+ (void)writeToLogFileSpecial: (NSString *)stringToWrite;
+ (void)writeToLogFile: (NSString *)stringToWrite;
+ (void)writeSeparatorToLogFile;

+ (NSString *)logFilePath;
+ (void)writeLogFileToDisk;

- (void)archiveData;

@end
