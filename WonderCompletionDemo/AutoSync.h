//
//  AutoSync.h
//  MiraList
//
//  Created by Jürgen Schwietering on 1/21/13.
//  Copyright (c) 2013 Jürgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoSync : NSObject


+ (id)handler;

- (void)startAction;
- (void)stopAction;
@end
