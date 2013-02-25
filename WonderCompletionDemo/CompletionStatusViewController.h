//
//  CompletionStatusViewController.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/26/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//
// scrutinize item


#import <UIKit/UIKit.h>

@class CompletionStatusViewController;

@protocol CompletionStatusViewControllerDelegate
- (void)completionStatusViewControllerDidFinish:(CompletionStatusViewController *)controller saveData:(BOOL)saveData;
@end

@interface CompletionStatusViewController : UIViewController <NSFetchedResultsControllerDelegate>

// id to be scrutinized
@property (weak, nonatomic) NSManagedObject *objectInEdit;

@property (weak, nonatomic) id <CompletionStatusViewControllerDelegate> delegate;

//@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *workersActiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysCompletionLabel;
@property (weak, nonatomic) IBOutlet UISlider *workersSlider;
@property (weak, nonatomic) IBOutlet UISlider *daysCompletionSlider;
@property (weak, nonatomic) IBOutlet UISwitch *completeNowSwitch;


- (IBAction)completeNowAction:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)workersSliderAction:(id)sender;
- (IBAction)daysCompletionSliderAction:(id)sender;


@end
