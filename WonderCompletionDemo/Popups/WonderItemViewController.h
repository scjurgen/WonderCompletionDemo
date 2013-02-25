//
//  WonderItemViewController.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/23/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WonderItemViewController;

@protocol WonderItemViewControllerDelegate

- (void)wonderItemViewControllerDidFinish:(WonderItemViewController *)controller cancel:(BOOL)cancel;
@end

@interface WonderItemViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id <WonderItemViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableOfProposedWonders;

// returns selected values
- (NSString*)getSelectedLocation;
- (NSString*)getSelectedName;

@end
