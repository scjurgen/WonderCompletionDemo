//
//  YourPersonalWonders.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/25/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YourPersonalWonders : NSManagedObject

@property (nonatomic) int16_t badgeUpdate;
@property (nonatomic) int32_t daysCompleted;
@property (nonatomic) int32_t daysToCompletion;
@property (nonatomic) NSTimeInterval lastStatusUpdate;
@property (nonatomic, retain) NSString * location;
@property (nonatomic) int32_t userOrder;
@property (nonatomic) int64_t wonderID;
@property (nonatomic, retain) NSString * wonderName;
@property (nonatomic) BOOL wonderTerminated;
@property (nonatomic) int32_t workersAssigned;

@end
