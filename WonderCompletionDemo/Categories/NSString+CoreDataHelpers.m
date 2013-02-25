//
//  NSString+CoreDataHelpers.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/24/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "NSString+CoreDataHelpers.h"

// used for creating letter based subsection in coredata
// i.e. "location.stringGroupByFirstInitial" as sectionNameKeyPath

@implementation NSString (CoreDataHelpers)

- (NSString *)stringGroupByFirstInitial {
    if (!self.length || self.length == 1)
        return self;
    return [self substringToIndex:1];
}


@end
