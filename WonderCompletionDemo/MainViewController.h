//
//  MainViewController.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "FlipsideViewController.h"
#import "WonderItemViewController.h"
#import "CompletionStatusViewController.h"

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController
    <FlipsideViewControllerDelegate,
    NSFetchedResultsControllerDelegate,
    WonderItemViewControllerDelegate,
    CompletionStatusViewControllerDelegate,
    UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableOfWonders;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
- (IBAction)addItem:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
- (IBAction)editTable:(id)sender;

- (IBAction)showInfo:(id)sender;
- (IBAction)editTableOnPressureAction:(id)sender;

@property (strong, nonatomic) UIPopoverController *wonderItemPopoverController;
@property (strong, nonatomic) UIPopoverController *completionStatusPopoverController;
@end
