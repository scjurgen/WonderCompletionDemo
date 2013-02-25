//
//  WonderItemForUpdate.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/24/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "WonderItem.h"

typedef enum _WISingleUpdateoperation{
    WIUpdate,
    WIAdd,
    WIDelete,
} WISingleUpdateoperation;

@interface WonderItemForUpdate : WonderItem

@property (atomic) WISingleUpdateoperation operation;

// the values of WonderItem to be updated will be nil if not to be changed.

@end
