//
//  MainViewController.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "MainViewController.h"
#import "WonderTableViewCell.h"
#import "CompletionStatusViewController.h"
#import "UserOrder.h"
#import "YourPersonalWonders.h"
#import "WonderItem.h"

#define kSortKey @"SortKey"
#define kDefaultSort @"userOrder"
#define kDefaultSortUser @"userOrder"


#ifdef DEBUG
#import "LogToFile.h"
#endif

@interface MainViewController ()
{
    BOOL isInEdit;
    CGFloat cellHeight;
    CGFloat originalPositionBeforeKeyboard;
    UserOrder *userOrder; // temporary storage for userorder
    UITextField *textFieldForDismiss;
}

@end

@implementation MainViewController

- (void)applyPaddedFooter {
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 170)];
	footer.backgroundColor = [UIColor clearColor];
	_tableOfWonders.tableFooterView = footer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isInEdit=NO;
    // peek height of cell
    NSString *nibName=([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"WonderCell_iPhone":@"WonderCell_iPad";
    WonderTableViewCell *cell= [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
    cellHeight=cell.bounds.size.height;
    [self applyPaddedFooter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,170)];
    [emptyView setBackgroundColor:[UIColor clearColor]];
    return emptyView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // small wonders, great wonders ???
    return cellHeight;
}


// this is a stupid hack to get the keyboard not over the last cells... should be adressed by adjusting views
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ((NSInteger)[[self.fetchedResultsController sections] count]-1==section)
        return 70;
    else
        return 10;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger maxSections=(NSInteger)[[self.fetchedResultsController sections] count];
    if (section==maxSections)
        return 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (WonderTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WonderCell";
    
    WonderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        NSString *nibName=([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"WonderCell_iPhone":@"WonderCell_iPad";
        cell = [[[NSBundle mainBundle] loadNibNamed:nibName
                                              owner:nil
                                            options:nil]
                lastObject];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (textFieldForDismiss)
        [self textFieldShouldEndEditing:textFieldForDismiss];

    
    CGRect rc=[tableView rectForRowAtIndexPath:indexPath];
    rc=[tableView convertRect:rc toView:[tableView superview]]; // relate to superview
    rc.size.width=150; // force arrow
    [self statusItem:object presentationRect:rc];
    // dismiss keyboard in edit
}

#pragma mark - Rearrange Items

-(void)checkUserorderRows
{
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"YourPersonalWonders" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kDefaultSortUser
                                                                   ascending:YES]]];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"ERROR: Fetch items error: %@", [error description]);
    }
    if (items==nil)
        return;
    if ([items count])
    {
        BOOL hasChanged=NO;
        for (NSInteger i=0; i<(NSInteger)[items count]; i++)
        {
            NSNumber *userSortOrder = [items[i] valueForKey:kDefaultSortUser];
            NSInteger oldRowInt = [userSortOrder integerValue];
            if (oldRowInt != i)
            {
                NSNumber *newRow=[NSNumber numberWithInteger:i];
                [items[i] setValue:newRow forKey:kDefaultSortUser];
                hasChanged=YES;
            }
        }
        if (hasChanged)
        {
            [_managedObjectContext save:&error];
            if (error)
            {
                NSLog(@"%@", error);
            }
        }
    }
}

-(void)MoveUserorderRow:(NSInteger)fromRow toRow:(NSInteger)toRow
{
        NSManagedObjectContext *context = _managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"YourPersonalWonders" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kDefaultSortUser
                                                                       ascending:YES]]];

        NSError *error;
        NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
        if (error)
        {
            NSLog(@"ERROR: Fetch items error: %@", [error description]);
        }
        if (items==nil)
            return;
        if ([items count])
        {
            if (fromRow < toRow) // moves up (rest rotates down)
            {
                // 0 [1 2 3] 4 5 6 7    1 to 3
                // 0 [2 3 1] 4 5 6 7
                // 0 2->1 3->2 1->3
                for (NSInteger i=fromRow; i<toRow; i++)
                {
                    NSNumber *newRow=[NSNumber numberWithInteger:i];
                    [items[i+1] setValue:newRow forKey:kDefaultSortUser];
                }
                NSNumber *newRow=[NSNumber numberWithInteger:toRow];
                [items[fromRow] setValue:newRow forKey:kDefaultSortUser];
            }
            // 0 [1 2 3] 4 5 6 7    3 to 1
            // 0 [3 1 2] 4 5 6 7
            // 0 3->1 1->2 2->3
            if (fromRow > toRow) // moves down (rest rotates up)
            {
                for (NSInteger i=toRow; i<fromRow; i++)
                {
                    NSNumber *newRow=[NSNumber numberWithInteger:i+1];
                    [items[i] setValue:newRow forKey:kDefaultSortUser];
                }
                NSNumber *newRow=[NSNumber numberWithInteger:toRow];
                [items[fromRow] setValue:newRow forKey:kDefaultSortUser];
            }
        }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;// all can be edited, maybe we should return NO on completed items
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"%@ %@",sourceIndexPath,destinationIndexPath);
    // adapt this if you use sections!!!
    [self MoveUserorderRow:sourceIndexPath.row toRow:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        //  [itemManager removeItem:indexPath.row];
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [_managedObjectContext deleteObject:object];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}



#pragma mark - Initial Seeding of item

- (void)wonderItemViewControllerDidFinish:(WonderItemViewController *)controller cancel:(BOOL)cancel
{
    //get data from controller
    NSString *initialName=[controller getSelectedName];
    NSString *initialLocation=[controller getSelectedLocation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [_wonderItemPopoverController dismissPopoverAnimated:NO];
    }
    if (cancel)
        return;
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
#ifdef DEBUG
    [[LogToFile handler] tagMsgWithTimestamp:@"items" message:@"new item creating"];
#endif
    // if these insertions get to massive consider chain of respsonibility and put in a new class in datamodel (initObjectWithNameAndLocation etc.)
    
    [newItem setValue:[NSNumber numberWithInteger:0] forKey:@"userOrder"];
    [newItem setValue:initialName forKey:kWonderName];
    [newItem setValue:initialLocation forKey:kLocation];
    [newItem setValue:[NSNumber numberWithInteger:(rand()%1000)*50+1000] forKey:kDaysToCompletion];
    [newItem setValue:[NSNumber numberWithInteger:0] forKey:kDayCompleted];
    [newItem setValue:[NSNumber numberWithInteger:(rand()%200)*5] forKey:kWorkersAssigned];
    [newItem setValue:[NSNumber numberWithInteger:1] forKey:@"badgeUpdate"];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        [[LogToFile handler] tagMsgWithTimestamp:@"items"
                                         message:[NSString stringWithFormat:@"new item creation failed, database error %@, %@",error, [error userInfo]]];
        // we could recopy the data
        abort();
    }
}

- (IBAction)addItem:(id)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        WonderItemViewController *controller = [[WonderItemViewController alloc] initWithNibName:@"WonderItemViewController" bundle:nil];
        controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:NO completion:nil];
    } else {
        if (!_wonderItemPopoverController) {
            WonderItemViewController *controller = [[WonderItemViewController alloc] initWithNibName:@"WonderItemViewController" bundle:nil];
            controller.delegate = self;
            controller.managedObjectContext = self.managedObjectContext;
            
            _wonderItemPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([_wonderItemPopoverController isPopoverVisible]) {
            [_wonderItemPopoverController dismissPopoverAnimated:YES];
        } else {
            UIButton *btn=sender;
            
            [_wonderItemPopoverController presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
}


#pragma mark - Scrutinize Item

- (void)completionStatusViewControllerDidFinish:(WonderItemViewController *)controller saveData:(BOOL)saveData
{
    if (saveData)
    {
        [_managedObjectContext save:nil];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [_completionStatusPopoverController dismissPopoverAnimated:NO];
    }

 }

- (void)statusItem:(NSManagedObject*)editThisObject presentationRect:(CGRect)presentationRect {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // keep alloc divided, we could use 2 different XIB for iPhone/iPad
        CompletionStatusViewController *controller = [[CompletionStatusViewController alloc] initWithNibName:@"CompletionStatusViewController" bundle:nil];
        controller.delegate = self;
        controller.objectInEdit = editThisObject;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:NO completion:nil];
    } else {
        if (!_completionStatusPopoverController) {
            CompletionStatusViewController *controller = [[CompletionStatusViewController alloc] initWithNibName:@"CompletionStatusViewController" bundle:nil];
            controller.delegate = self;
            _completionStatusPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        
        CompletionStatusViewController *ctrl = (CompletionStatusViewController *)_completionStatusPopoverController.contentViewController;
        ctrl.objectInEdit = editThisObject;
        if ([_completionStatusPopoverController isPopoverVisible]) {
            [_completionStatusPopoverController dismissPopoverAnimated:YES];
        } else {
            [_completionStatusPopoverController presentPopoverFromRect:presentationRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        } 
    }
}

#pragma mark - Table edit request

- (IBAction)editTable:(id)sender {
    if (isInEdit)
    {
        NSError *error;
        [_managedObjectContext save:&error];
        if (error)
        {
            NSLog(@"%@", error);
        }
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        isInEdit=NO;
        [_tableOfWonders setEditing:NO animated:YES];
        [_tableOfWonders reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kWIStoppedEditNotification object:nil];
    }else{
        [self checkUserorderRows];
        [_editButton setTitle:@"Done" forState:UIControlStateNormal];
        isInEdit=YES;
        [_tableOfWonders setEditing:YES animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWIInEditNotification object:nil];
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)editTableOnPressureAction:(id)sender {
    NSLog(@"Long pressure edit TBD");
    if (!isInEdit)
        [self editTable:nil];
}


#pragma mark - Fetched results controller

- (void)ChangeOrder:(NSString *)newOrderKey
{
    _fetchedResultsController=nil;
    [self fetchedResultsController];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"YourPersonalWonders"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    NSString*sortkey=[[NSUserDefaults standardUserDefaults] stringForKey:kSortKey];
    if (sortkey==nil)
        sortkey=kDefaultSort;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortkey
                                                                   ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"Mastercache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
#ifdef DEBUG
	    DVLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
#endif
	}
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_tableOfWonders beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableOfWonders insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableOfWonders deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableOfWonders insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableOfWonders deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_tableOfWonders reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableOfWonders deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableOfWonders insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableOfWonders endUpdates];
}

#pragma mark - Cell Configuration/Editing


- (void)keyboardWillShow:(NSNotification *)aNotification {
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSError *error;
    [_managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@", error);
    }
}


- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWIInEditNotification object:nil];
    UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [_tableOfWonders scrollToRowAtIndexPath:[_tableOfWonders indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    textFieldForDismiss=textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isFirstResponder])
    {
        [textField resignFirstResponder];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    textFieldForDismiss=nil;
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    NSInteger item=textField.tag&0x01; // mask item
    NSInteger index=textField.tag>>1; // shift out index
    NSUInteger indexTupel[2]={0,index};
    NSIndexPath *indexPath=[[NSIndexPath alloc] initWithIndexes:indexTupel length:2];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    switch (item)
    {
        case 0:
            [object setValue:textField.text forKey:kWonderName];
            break;
        case 1:
            [object setValue:textField.text forKey:kLocation];
            break;
    }
    NSError *error;
    [_managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@", error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kWIStoppedEditNotification object:nil];
    //[_tableOfWonders reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWIStoppedEditNotification object:nil];
    return NO;
}


/**
 tag for editing is calculated by masking the Integer, Bit 31..1 = index.row Bit0: {name|location}
 this could be also nice with a struct bitset remapped. i.e.: {uint row:16; uint item:8};
 */
- (void)configureCell:(WonderTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    cell.tag=indexPath.row;
    cell.nameOfWonderTextField.tag=(indexPath.row<<1);
    cell.locationTextField.tag=(indexPath.row<<1)+1;
    cell.nameOfWonderTextField.delegate=self;
    cell.locationTextField.delegate=self;
    // using description, be on the robust side
    cell.nameOfWonderTextField.text = [[object valueForKey:kWonderName] description];
    cell.locationTextField.text = [[object valueForKey:kLocation] description];
    cell.daysToCompletionLabel.text = [[object valueForKey:kDaysToCompletion] description];
    cell.daysCompletedLabel.text = [[object valueForKey:kDayCompleted] description];
    cell.workersAssignedLabel.text = [[object valueForKey:kWorkersAssigned] description];
    cell.userOrderLabel.text = [[object valueForKey:@"userOrder"] description];
   
    if ([[object valueForKey:kDaysToCompletion] integerValue] <= [[object valueForKey:kDayCompleted] integerValue])
    {
        cell.badgeUpdateImageView.image=[UIImage imageNamed:@"completedItem"];
    }
    else
    {
        cell.badgeUpdateImageView.image=nil;
    }
}


@end
