//
//  FlipsideViewController.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "FlipsideViewController.h"
#import "WebNewsEngine.h" 
// WebNewsEngine some old stuff, but handy, would be nice to adapt to a Core ManagedObject

@implementation ExtUIWebView

// needs eventually be implemented if we want to talk to our webpage
- (void)webViewDidFinishLoad
{
}

@end

@interface FlipsideViewController ()
{
    WebNewsEngine * wnEngine;
}
@end

@implementation FlipsideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
        else
        self.contentSizeForViewInPopover = CGSizeMake(768.0, 1004.0);
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
}


- (void) viewWillAppear:(BOOL)animated
{
    wnEngine = [[WebNewsEngine alloc] init];
    [wnEngine defineTemplate:@"InfoScreen"];
    
    [_extInfoWebView loadHTMLString:[wnEngine CreateHtml] baseURL:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kWICompletionWithAudioNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    wnEngine=nil;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
