//
//  ProposedOpusViewCell.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
daysCompleted
daysToCompletion
userOrder
workersAssigned
wonderID
location
wonderName
wonderTerminated
*/
@interface ProposedOpusViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;

@end
