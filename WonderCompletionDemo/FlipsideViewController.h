//
//  FlipsideViewController.h
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtUIWebView : UIWebView
@end

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet ExtUIWebView *extInfoWebView;

- (IBAction)done:(id)sender;

@end
