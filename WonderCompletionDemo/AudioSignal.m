//
//  AudioSignal.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/27/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "AudioSignal.h"

@interface AudioSignal()
{
    CFURLRef		soundFileURLRef;
    SystemSoundID	soundFileObject;
}
@end


@implementation AudioSignal

+ (id)handler {
    static AudioSignal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}


- (id) init {
    self=[super init];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    AudioServicesDisposeSystemSoundID (soundFileObject);
    CFRelease (soundFileURLRef);
    soundFileURLRef=nil;
    soundFileObject=0;
}

- (void)startReceiveNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playAlertSound:)
                                                 name:kWICompletionWithAudioNotification
                                               object:nil];
}

- (void)playAlertSound:(NSNotification *)notification
{
    @try {
        if (!soundFileURLRef)
        {
            NSURL *tapSound = [[NSBundle mainBundle] URLForResource:@"WonderCompletion"
                                                      withExtension: @"aif"];
            soundFileURLRef = (__bridge CFURLRef)tapSound;
        }
        AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
        AudioServicesPlayAlertSound (soundFileObject);
    }
    @catch (NSException *exception) {
        NSLog(@"Exception crash");
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AudioServicesDisposeSystemSoundID (soundFileObject);
    CFRelease (soundFileURLRef);

}

@end
