//
//  AppDelegate.m
//  WonderCompletionDemo
//
//  Created by Jürgen Schwietering on 1/22/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

/*!
 
 This documentation can be found in the AppDelegate.m, it uses the <a href="http://www.stack.nl/~dimitri/doxygen/commands.html">doxygen syntax</a>.
 \mainpage Wunderdemo
 
 To recreate the documentation run the <tt>createdox.sh.command</tt> command in the <tt>./Documentation</tt> folder (use bash).
 You will need to install <a href="http://www.stack.nl/~dimitri/doxygen/download.html#latestsrc">Doxygen</a> first.
 

 \section intro_sec Introduction
 
 This application simulates a completion of personal wonders.
 
 
 The program has the following main tasks
 \li Create list items
 \li Change values on them
 \li Order or delete them as you prefer
 \li Simulate synchronization with a backend to update the work complete
 \li Completed items are signaled (audio and checkmark)
 
 \subsection

 \subsection localization
 Once stable use in the console
 <pre>
 genstrings ./Classes/\*.m
 </pre>
 to generate Localizable.strings, make sure that while importing into xcode to transform to UTF-16, open info, make file localizable, add languages by adding 2letter codes (de,it,fr,es,pt etc.)
 
 \section Tips_sec Tips and Tricks for debugging
 
 \subsection browsedb_sec Browsing database content
 to open the database for browsing you should download base.app . you can then browse the database by using the path you copy from the log i.e.:
 
 <pre>
 #just an example, the path is written in the console
 cd "/Users/juergen/Library/Application Support/iPhone Simulator/5.1/Applications/01FBD44C-BD16-478B-8CD1-85CBDC256764/Documents"
 ls -l *sqlite
 open -a Base *sqlite
 </pre>
 
 \subsection Browsedata_sec Browsing data of users documents
 to browse the files downloaded in the finder (as you usually will not see the Library):
 <tt>open -a finder "/Users/juergen/Library/Application Support/iPhone Simulator/5.1/Applications/01FBD44C-BD16-478B-8CD1-85CBDC256764/Documents"</tt>
 
 \section Libraries
 
 \subsection MKNetworkKit
 MKNetworkKit is used for download and upload of data, images. It's used also to test the Reachability of the network while the syncronization process is taking place.
 
 
 \subsection ELCImagePicker ELCImagePickerController
 ELCImagePicker is used to load the photo and video library to select some photos or videos before the upload process to the server.
 
 
 */




#import "AppDelegate.h"
#import "StorageManager.h"
#import "MainViewController.h"
#import "AudioSignal.h"
#import "AutoSync.h"

/**
 just a hint:
 store coordinator is in StorageManger.m
 */

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
    } else {
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.mainViewController;
    self.mainViewController.managedObjectContext = [[StorageManager handler] managedObjectContext];
    [self.window makeKeyAndVisible];
    [[AutoSync handler] startAction];
    [[AudioSignal handler] startReceiveNotifications];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[StorageManager handler] saveContext];
}

@end
