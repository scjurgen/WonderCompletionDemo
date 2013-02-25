//
//  UserOrder.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/24/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserOrder : NSObject

@property (atomic) BOOL isEditing;
@property (nonatomic, strong) NSMutableArray *items;

-(id)initWithCount:(NSInteger)itemCount;

-(void)startEdit;
-(void)endEdit;
-(void)removeItem:(NSInteger)index;
-(void)moveItem:(NSInteger)from to:(NSInteger)to;

-(NSInteger)getItemOfActiveListAsInteger:(NSInteger)index;
-(void)getItemOfActiveListWithBlock:(NSInteger)index
    block:(void(^)(id item))block;

@end
