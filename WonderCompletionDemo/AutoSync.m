//
//  AutoSync.m
//
//  Created by Jürgen Schwietering on 1/21/13.
//  Copyright (c) 2013 Jürgen Schwietering. All rights reserved.
//

// singleton that will manage automatic synching of user account data
// download success will send a system wide notification to block update UIF, update coredata, smooth update UIFC
// this simulation will dispatch on a different thread so it simulates async network operations
// the simulation contains 3 steps
// main thread, get current items
// different thread, manipulate items
// main thread update db
// this needs refactoring to change responsibility of datamanipulation in a specific datamodel class

#import "AutoSync.h"
#import "StorageManager.h"
#import "WonderItem.h"
#import "WonderItemForUpdate.h"
#import "MKNetworkKit.h"

// to test robustness and UIF issues set interval to a lower value
#define UPDATEINTERVAL 10.0f

@interface AutoSync()
{
    NSTimer *syncSimulator;
    BOOL active;
    BOOL isEditing;
    NSMutableDictionary *activeItems;
}
@end

@implementation AutoSync

+ (id)handler {
    static AutoSync *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // launch once, make sure of correct singleton
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


// we need an observer, to avoid context sves during critical edit

- (id)init
{
    self=[super init];
    if (self)
    {
        syncSimulator = [NSTimer timerWithTimeInterval:UPDATEINTERVAL target:self selector:@selector(incrementWork:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:syncSimulator forMode:NSRunLoopCommonModes];
        active=NO;
        isEditing=NO;
        
        // not removed, they persist during the livetime
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(isEditing:)
                                                     name:kWIInEditNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stoppedEditing:)
                                                     name:kWIStoppedEditNotification
                                                   object:nil];
    }
    return self;
}

- (void)isEditing:(NSNotification *)notification
{
    DVLog(@"AutoSync receives: is editing");
    isEditing=YES;
}

- (void)stoppedEditing:(NSNotification *)notification
{
    DVLog(@"AutoSync receives: is NOT editing");
    isEditing=NO;
}

-(void)startAction
{
    active=YES;
    DVLog(@"Autoupdate started");
}

-(void)stopAction
{
    active=NO;
}



-(void)incrementWork:(id)userInfo
{
    [self ReadCurrentData];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DVLog(@"Updating randomly data on db (substitute this with network driven updates)");
        MKNetworkEngine* eng = [[MKNetworkEngine alloc] initWithHostName:@"www.nerdware.net" customHeaderFields:nil];
        NSString * OpPath = @"/wondercompletion/workload.php";
        
        MKNetworkOperation __weak *downloadOp = [eng operationWithPath:OpPath
                                                                        params:nil
                                                                    httpMethod:@"GET"];
        
        [downloadOp addHeaders:[NSDictionary dictionaryWithObject:@"application/json" forKey:@"Accept"] ];
        
        [downloadOp onCompletion:^(MKNetworkOperation *completedOperation) {
            int statusCode = [completedOperation HTTPStatusCode];
            NSLog(@"statusCode %i",statusCode);
            NSLog(@"responseString:%@",[completedOperation responseString]);
            if (statusCode == 200) {
                [self IncrementCurrentData];
                dispatch_async( dispatch_get_main_queue(), ^{
                    // new data ready, add to update queue
                    DVLog(@"Update received");
                    [self StoreData];
                });
            }
            
        } onError:^(NSError *error) {
            NSLog(@"error download %@",error);
            if ([downloadOp HTTPStatusCode] == 403) {
            }
        }];
        
        [downloadOp onDownloadProgressChanged:^(double progress) {
            
        }];
        
        [eng enqueueOperation:downloadOp];
        
    });
}

#pragma mark - Database hokus pokus


-(void)ReadCurrentData
{
    @synchronized(self)
    {
        NSManagedObjectContext *context = [[StorageManager handler] managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"YourPersonalWonders" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        
        // work on active items only
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"daysCompleted < daysToCompletion"];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
        if (error)
        {
            NSLog(@"ERROR: Fetch items error: %@", [error description]);
        }
        if (items==nil)
            return;
        activeItems=nil;
        if ([items count])
        {
            activeItems=[[NSMutableDictionary alloc]initWithCapacity:[items count]];
            for (NSManagedObject *item in items) {
                id daysCompleted = [item valueForKey:kDayCompleted];
                if(![daysCompleted isKindOfClass:[NSNumber class]])
                    NSAssert(0,@"expected daysCompleted column NSNumber");
                
                // we need only some items for the simulation
                WonderItemForUpdate *wItem=[[WonderItemForUpdate alloc]init];
                
                wItem.daysCompleted=daysCompleted;
                wItem.workersAssigned=[item valueForKey:kWorkersAssigned];
                wItem.daysToCompletion=[item valueForKey:kDaysToCompletion];
                [activeItems setObject:wItem forKey:[item valueForKey:kWonderName]];
            }
        }
    }
}


-(void)IncrementCurrentData
{
    @synchronized(self)
    {
        if (!activeItems)
            return;
        NSMutableDictionary *newDictionary=[[NSMutableDictionary alloc]initWithCapacity:10];
        [activeItems enumerateKeysAndObjectsUsingBlock:^(NSString * key, WonderItemForUpdate *item, BOOL *stop){
            
            NSInteger workersAssigned=[item.workersAssigned integerValue];
            if (workersAssigned>0)
            {
                // well, would be better to use scalar stuff...
                NSInteger oldValue=[item.daysCompleted integerValue];
                NSInteger finalDays=[item.daysToCompletion integerValue];
                oldValue+=workersAssigned/2; // many do work
                oldValue+=rand()%(workersAssigned/2); // some don't
                if (oldValue > finalDays)
                {
                    oldValue=finalDays;
                    [[NSNotificationCenter defaultCenter]postNotificationName:kWICompletionWithAudioNotification object:nil];
                }
                item.daysCompleted = [NSNumber numberWithInteger:oldValue];
                [newDictionary setValue:item forKey:key]; // can't go inplace
            }
            *stop=NO;
        } ];
        activeItems=newDictionary;
    }
}


-(void)StoreData
{
    @synchronized(self)
    {
        if (!activeItems)
            return;
        if (!isEditing)
        {
            NSManagedObjectContext *context = [[StorageManager handler] managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"YourPersonalWonders" inManagedObjectContext:context];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            NSError *error;
            NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
            if (!items)
                return;
            BOOL hasBeenUpdated=NO;
            for (NSManagedObject *item in items) {
                WonderItemForUpdate *updatedItem = [activeItems objectForKey:[item valueForKey:kWonderName]];
                if (updatedItem)
                {
                    hasBeenUpdated=YES;
                    [item setValue:updatedItem.daysCompleted forKey:kDayCompleted];
                }
            }
            if (hasBeenUpdated)
            {
                DVLog(@"Storing changed context");
                [context save:&error];
                if (error)
                {
                    NSLog(@"ERROR: Storing items error: %@", [error description]);
                }
            }
        }
        else{
            DVLog(@"is editing, delayed transaction");
        }
    }
}

@end
