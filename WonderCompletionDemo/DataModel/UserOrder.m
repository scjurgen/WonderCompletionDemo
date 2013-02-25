//
//  UserOrder.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/24/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "UserOrder.h"

@implementation UserOrder

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCount:(NSInteger)itemCount
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc]initWithCapacity:itemCount];
        for (int i=0; i < itemCount; i++)
        {
            NSNumber *item=[NSNumber numberWithInteger:i];
            [_items addObject:item];
        }
    }
    return self;
}

- (void)startEdit
{
    self.isEditing=YES;
}

- (void)endEdit // just don't do anything
{
    self.isEditing=NO;

}

// save new arrangement and terminate editing mode
- (void)saveEdit
{
    if (!self.isEditing)
        return;
    self.isEditing=NO;
}

- (void)removeItem:(NSInteger)index
{
    if (!self.isEditing)
        return;
    [_items removeObjectAtIndex:index];
}


- (void)moveItem:(NSInteger)from to:(NSInteger)to
{
    if (!self.isEditing)
        return;
    id item = [_items objectAtIndex:from];
    [_items removeObjectAtIndex:from];
    [_items insertObject:item atIndex:to];
}


/** trust that we have objects that responds to integerValue
 */
- (NSInteger)getItemOfActiveListAsInteger:(NSInteger)index
{
    if (index < (NSInteger)[_items count])
    {
        // a selector test could be good
        /*
         if (!responds to select integerValue)
            NSAssert(...);
         */
        return [[_items objectAtIndex:index] integerValue];
    }
    else
    {
        return -1;
    }
}

-(void)getItemOfActiveListWithBlock:(NSInteger)index
                              block:(void(^)(id item))block
{
    if (index < (NSInteger)[_items count])
    {
        block([_items objectAtIndex:index]);
    }
    else
    {
        block(nil);
    }
}



@end
