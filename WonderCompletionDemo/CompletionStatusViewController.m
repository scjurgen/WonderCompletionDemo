//
//  CompletionStatusViewController.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/26/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "CompletionStatusViewController.h"

#import "WonderItem.h"


// using sliders normalized, easier to tweak here than in IB
#define kFactorWorkers 1000.0f
#define kFactorDays 20000.0f

@interface CompletionStatusViewController ()
{
    NSInteger daysToCompletion;
    NSInteger daysCompleted;
    NSInteger workersAssigned;
}
@end

@implementation CompletionStatusViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    _nameTextField.text=[[_objectInEdit valueForKey:kWonderName] description];
    _locationTextField.text=[[_objectInEdit valueForKey:kLocation] description];
    
    daysCompleted=[[_objectInEdit valueForKey:kDayCompleted] integerValue];
    daysToCompletion=[[_objectInEdit valueForKey:kDaysToCompletion] integerValue];
   
    NSNumber *workers=[_objectInEdit valueForKey:kWorkersAssigned];
    workersAssigned=[workers integerValue];
    _workersSlider.value =  (CGFloat)workersAssigned/kFactorWorkers;
    _workersActiveLabel.text = [workers description];
    
    _daysCompletionSlider.value =  (CGFloat)daysToCompletion/kFactorDays;
    _daysCompletionLabel.text = [[_objectInEdit valueForKey:kDaysToCompletion] description];
    [self evalStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(id)sender {
    [self.delegate completionStatusViewControllerDidFinish:self saveData:NO];
}

- (IBAction)done:(id)sender {
    // store data

    [_objectInEdit setValue:_nameTextField.text forKey:kWonderName];
    [_objectInEdit setValue:_locationTextField.text forKey:kLocation];
    [_objectInEdit setValue:[NSNumber numberWithInteger:workersAssigned] forKey:kWorkersAssigned];
    [_objectInEdit setValue:[NSNumber numberWithInteger:daysToCompletion] forKey:kDaysToCompletion];
    [self.delegate completionStatusViewControllerDidFinish:self saveData:YES];
}

- (void)evalStatus
{
    CGFloat percent=roundf((CGFloat)daysCompleted*100.0f/(CGFloat)daysToCompletion);
    if (percent >= 100.0f)
        _statusLabel.text = @"Done";
    else
        if (workersAssigned == 0)
            _statusLabel.text = @"Never (no workers)";
        else
            _statusLabel.text = [NSString stringWithFormat:@"%.1f %%",roundf((CGFloat)daysCompleted*1000.0f/(CGFloat)daysToCompletion)/10.0f];

}

- (IBAction)workersSliderAction:(id)sender {
    workersAssigned=(NSInteger)(_workersSlider.value*kFactorWorkers);
    _workersActiveLabel.text = [NSString stringWithFormat:@"%d", workersAssigned];
    [self evalStatus];
}

- (IBAction)daysCompletionSliderAction:(id)sender {
    daysToCompletion=(NSInteger)(_daysCompletionSlider.value*kFactorDays);
    [self evalStatus];
    _daysCompletionLabel.text = [NSString stringWithFormat:@"%d",daysToCompletion];

}




- (void)shareAction:(UIButton*)sender
{
    // free this to add sharekit stuff on button
    /*
    NSString *twitterAccount = SHKCONFIG(twitterUsername);
    if(twitterAccount)
        twitterAccount = [NSString stringWithFormat:@" via @%@", twitterAccount];
    SHKItem *item = [SHKItem text:[NSString stringWithFormat:@"%@  \n %@    \n Suivez les Jeux Olympiques en direct, en vidéo et en intégralité sur francetv sport: http://www.francetv.fr/sport/les-jeux-olympiques-2012%@", self.articleSelected.newstitle,  self.articleSelected.url, twitterAccount]];
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [actionSheet showInView:self.view];
     */
}


- (IBAction)completeNowAction:(id)sender {
}
@end
