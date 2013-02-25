//
//  WonderTableViewCell.h
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
@interface WonderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *nameOfWonderTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;

@property (weak, nonatomic) IBOutlet UILabel *daysToCompletionLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysCompletedLabel;
@property (weak, nonatomic) IBOutlet UILabel *workersAssignedLabel;
@property (weak, nonatomic) IBOutlet UILabel *userOrderLabel;

@property (weak, nonatomic) IBOutlet UIImageView *badgeUpdateImageView;

@end
