//
//  WonderItemViewController.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/23/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

// manage a list of proposed wonders these are preloaded in the database and could be updated with a delta i.e.
// rm idx,
// add idx,name,location etc.
// this could also be done with a Flyweight to reduce significant performance overhead
// a bit of overhead here, this class is actually reading a static table that until not is not changing.

#import "WonderItemViewController.h"
#import "StorageManager.h"
#import "ProposedOpusViewCell.h"
#import "NSString+CoreDataHelpers.h"


@interface WonderItemViewController ()
{
    NSIndexPath *selectedItemIndexpath;
    CGFloat cellHeight;
}

@end

@implementation WonderItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _managedObjectContext = [[StorageManager handler] managedObjectContext];
    ProposedOpusViewCell *cell= [[[NSBundle mainBundle] loadNibNamed:@"ProposedOpus" owner:nil options:nil] lastObject];
    cellHeight=cell.bounds.size.height;
}

- (void)viewWillAppear:(BOOL)animated
{
    selectedItemIndexpath=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _fetchedResultsController=nil;
    _managedObjectContext=nil;
}

- (IBAction)cancel:(id)sender {
    [self.delegate wonderItemViewControllerDidFinish:self cancel:YES];
}

- (IBAction)done:(id)sender {
    [self.delegate wonderItemViewControllerDidFinish:self cancel:NO];
}

#pragma mark - table view


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // small wonders, great wonders ???
    return cellHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int maxSections=[[self.fetchedResultsController sections] count];
    if (section==maxSections)
        return 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (ProposedOpusViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WonderCell";
    
    ProposedOpusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ProposedOpus" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedItemIndexpath=indexPath;
}

#pragma mark - Fetched results controller


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProposedWonders" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptorLocation = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *sortDescriptors = @[sortDescriptorLocation,sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"location"
                                                   cacheName:nil];
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
    [_tableOfProposedWonders beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableOfProposedWonders insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableOfProposedWonders deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableOfProposedWonders insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableOfProposedWonders deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_tableOfProposedWonders reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableOfProposedWonders deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableOfProposedWonders insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableOfProposedWonders endUpdates];
}

#pragma mark - TabelViewCell configure

- (void)configureCell:(ProposedOpusViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    cell.nameLabel.text= [[object valueForKey:@"name"] description];
    cell.additionalInfoLabel.text =[[object valueForKey:@"location"] description];
}


#pragma mark - access selected data of item

- (id) getValueOfSelection:(NSString*)key
{
    if (selectedItemIndexpath==nil)
        return @"n/a";
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:selectedItemIndexpath];
    return [object valueForKey:key];
}

- (NSString*)getSelectedLocation
{
    return [self getValueOfSelection:@"location"];
}

- (NSString*)getSelectedName
{
    return [self getValueOfSelection:@"name"];
}



@end
