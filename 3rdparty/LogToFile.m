//
//  LogToFile.m
//  Created by Jürgen Schwietering on 8/22/12.
//  Copyright (c) 2012 Jürgen Schwietering All rights reserved.
//

#import "LogToFile.h"
#include <sys/stat.h>

// static methods to log to a file
// might come in handy for tracking server response times i.e.

@implementation LogToFile

-(id)init
{
    self=[super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        _dataPath=[documentsDir stringByAppendingPathComponent:@"logs"];
        mkdir([_dataPath UTF8String], 0755);
        DVLog(@"Logging seems enabled! Data directory is:\n\ncd \"%@\"\n\nfor tracking try this in the terminal\n\ntail -f \"%@\"\n",_dataPath,_dataPath);
    }
    return self;
}

+ (id)handler {
    static LogToFile *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];

    });
    return sharedInstance;
}

/**
 convienience method
 append log message into users document path logfile named main.log
 */
- (void)msg:(NSString *)message {
#ifdef DEBUG
  NSString *fname = [_dataPath stringByAppendingPathComponent:@"main.log"];
  FILE *fp = fopen([fname UTF8String],"a+b");
  if (fp)
  {
    fprintf(fp,"%s\r\n",[message UTF8String]);
    fclose(fp);
  }
#endif
}

/**
 append log message to users document path logfile named {logFileTag}.log
 */
- (void)tagMsg:(NSString*)logFileTag message:(NSString *)message {
#ifdef DEBUG
    NSString *fname = [_dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", logFileTag]];
    FILE *fp = fopen([fname UTF8String],"a+b");
    if (fp)
    {
        fprintf(fp,"%s\r\n",[message UTF8String]);
        fclose(fp);
    }
#endif
}

/**
append log message to users document path logfile named {logFileTag}.log with timestamp
 */
- (void)tagMsgWithTimestamp:(NSString*)logFileTag message:(NSString *)message {
    NSDate* currentDate = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];

    //int msecs= (int)fmod(([currentDate timeIntervalSince1970] * 1000),1000.0);
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH':'mm':'ss'.'SSS"];
    NSString * converted= [dateFormatter stringFromDate:currentDate];
    NSString* tsmsg = [NSString stringWithFormat:@"%@: %@",converted, message];
    [self tagMsg:logFileTag message:tsmsg];
}

@end
