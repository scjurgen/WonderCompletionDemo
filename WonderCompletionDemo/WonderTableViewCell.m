//
//  WonderTableViewCell.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

/**
 cells have NO autolayout, there is a bug (?) in 
 iOS which would not resize a custom cell if in table edit mode
 */


#import "WonderTableViewCell.h"

@implementation WonderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
