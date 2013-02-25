//
//  LogToFile.h
//
//  Created by Jürgen Schwietering on 8/22/12.
//  Copyright (c) 2012 Jürgen Schwietering All rights reserved.
//

#import <Foundation/Foundation.h>


#define TRACELOG 


@interface LogToFile : NSObject

@property (strong,nonatomic,readonly) NSString *dataPath;

+ (id)handler;

- (void)msg:(NSString *)message;
- (void)tagMsg:(NSString*)logFileTag message:(NSString *)message;
- (void)tagMsgWithTimestamp:(NSString*)logFileTag message:(NSString *)message;

@end
