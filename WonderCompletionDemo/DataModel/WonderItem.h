//
//  WonderItem.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/24/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.

#import <Foundation/Foundation.h>

#define kWonderName @"wonderName"
#define kLocation @"location"
#define kDayCompleted @"daysCompleted"
#define kDaysToCompletion @"daysToCompletion"
#define kWorkersAssigned @"workersAssigned"
#define kUserOrder @"userOrder"

@interface WonderItem : NSObject

@property (strong,nonatomic) NSNumber *wonderID;
@property (strong,nonatomic) NSString *wonderName;
@property (strong,nonatomic) NSString *location;
@property (strong,nonatomic) NSNumber *daysToCompletion;
@property (strong,nonatomic) NSNumber *daysCompleted;
@property (strong,nonatomic) NSNumber *workersAssigned;
@property (strong,nonatomic) NSNumber *userOrder;

//-(void) initWithRandomWonder;

@end
