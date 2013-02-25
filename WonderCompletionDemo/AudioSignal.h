//
//  AudioSignal.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/27/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioSignal : NSObject

+ (id)handler;
- (void)startReceiveNotifications;

@end
