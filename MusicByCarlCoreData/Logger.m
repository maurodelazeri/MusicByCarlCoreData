//
//  Logger.m
//  DealSiftr
//
//  Created by Carleton Smith on 11/5/13.
//  Copyright (c) 2013 Carleton Smith. All rights reserved.
//

#import "Logger.h"
#import "Utilities.h"

@implementation Logger

// This class method initializes the static singleton pointer
// if necessary, and returns the singleton pointer to the caller
+ (Logger *)sharedLogger
{
    static dispatch_once_t pred = 0;
    __strong static Logger *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [self loadInstance];
    });
    return _sharedObject;
}

- (NSMutableArray *)logMessages
{
    if (!_logMessages)
    {
        _logMessages = [[NSMutableArray alloc] init];
    }
    
    return _logMessages;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    
    if (self)
    {
        _logMessages = [decoder decodeObjectForKey:@"logMessages"];
    }
    else
    {
        _logMessages = nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.logMessages forKey:@"logMessages"];
}

- (void)archiveData
{
    NSString *archivePath = [Utilities loggerArchiveFilePath];
    [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
}

+(instancetype)loadInstance
{
    NSString *archivePath = [Utilities loggerArchiveFilePath];
    NSData *decodedData = [NSData dataWithContentsOfFile:archivePath];
    if (decodedData)
    {
        Logger *loggerData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return loggerData;
    }
    
    return [[Logger alloc] init];
}

+ (void)writeToLogFile: (NSString *)stringToWrite
{
    [Logger commonMemoryLogger:stringToWrite withTimeStamp:YES];
}

+ (void)writeToLogFileSpecial: (NSString *)stringToWrite
{
    [Logger commonMemoryLogger:stringToWrite withTimeStamp:YES];
}

+ (void)commonMemoryLogger: (NSString *)stringToWrite withTimeStamp: (BOOL)timeStampFlag
{
    NSLog(@"%@", stringToWrite);
    
    NSString *logString = @"";
    
    if (timeStampFlag)
    {
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentTime = [DateFormatter stringFromDate:[NSDate date]];
        
        logString = [logString stringByAppendingString:[NSString stringWithFormat:@"%@: ", currentTime]];
    }
    
    logString = [logString stringByAppendingString:stringToWrite];
    
    [[Logger sharedLogger].logMessages addObject:logString];
}

+ (void)commonDiskLogger: (NSString *)stringToWrite withTimeStamp: (BOOL)timeStampFlag
{
    NSLog(@"%@", stringToWrite);
    
    NSString *documentsDir = [Utilities documentsDirectoryPath];
    
    NSString *logFilePath = [documentsDir stringByAppendingPathComponent:@"MusicByCarlCoreDataLog.txt"];
    
    NSError *error;
    
    NSString *contents = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:&error];

    if (contents == nil)
    {
        // Assume that we're writing to the file for the first time
        contents = @"";
        NSLog(@"%@", logFilePath);
    }
    else
    {
        contents = [contents stringByAppendingString:@"\n"];
    }
    
    if (timeStampFlag)
    {
        NSString *currentTime = [Utilities dateToString:[NSDate date]];
        
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"%@: ", currentTime]];
    }
    
    contents = [contents stringByAppendingString:stringToWrite];
        
    if (![contents writeToFile:logFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"Error writing to log file (%@): %@", logFilePath, error);
    }
}

+ (void)writeSeparatorToLogFile
{
    [Logger commonMemoryLogger:@"#################################################################################################################################################"withTimeStamp:NO];
}

+ (void)writeLogFileToDisk
{
    NSString *logFilePath = [Logger logFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    if ([fileManager fileExistsAtPath:logFilePath])
    {
        if (![fileManager removeItemAtPath:logFilePath error:&error])
        {
            NSLog(@"Error deleting log file (at path %@): %@", logFilePath, error);
        }
    }
    
    NSString *contents = @"";
    
    Logger *loggerSingleton = [Logger sharedLogger];
    
    for (int i = 0; i < loggerSingleton.logMessages.count; i++)
    {
        contents = [contents stringByAppendingFormat:@"%@\n", [loggerSingleton.logMessages objectAtIndex:i]];
    }
    
    if ([contents writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        [loggerSingleton.logMessages removeAllObjects];
    }
    else
    {
        NSLog(@"Error writing to log file (at path %@): %@", logFilePath, error);
    }
}

+ (NSString *)logFilePath
{
    NSString *documentsDir = [Utilities documentsDirectoryPath];
    
    return [documentsDir stringByAppendingPathComponent:@"MusicByCarlCoreDataLog.txt"];
}

@end
