//
//  AppDelegate.m
//  djcharts
//
//  Created by Corey Donohoe on 12/9/14.
//  Copyright (c) 2014 Corey Donohoe. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    NSImage *icon = [NSImage imageNamed:@"headphones"];
    [icon setTemplate:YES];
    
    [_statusItem setImage:icon];
    _statusItem.highlightMode = YES;

    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Open DJ Charts" action:@selector(openDJCharts:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Update" action:@selector(refreshDJCharts:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                  target: self
                  selector:@selector(onPulse:)
                  userInfo: nil repeats:YES];
    return;
    timer = nil; // lol
}

- (void)onPulse:(NSTimer *)timer {
  NSLog(@"Periodic Pulse.");
  NSTask *task;
  NSArray *arguments = [NSArray arrayWithObject: @"hi atmos"];

  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"traktor-charts" ofType:nil];

  task = [[NSTask alloc]init];
  [task setLaunchPath: filePath];
  [task setArguments: arguments];
  [task launch];
  [task waitUntilExit];

  int exitStatus = [task terminationStatus];
  if(exitStatus == 0) {
    NSLog(@"Exited successful. :+1:.");
  } else if(exitStatus == 2) {
    NSLog(@"Probably failed to post to djcharts.io");
  } else if(exitStatus == 3) {
      NSLog(@"No new traktor archive files found.");
  } else {
    NSLog(@"Exited with %d", [task terminationStatus]);
  }
}

- (void)openDJCharts:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://djcharts.io/"]];
}

- (void)refreshDJCharts:(id)sender {
    NSTask *task;
    NSArray *arguments = [NSArray arrayWithObject: @"hi atmos"];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"traktor-charts" ofType:nil];

    task = [[NSTask alloc]init];
    [task setLaunchPath: filePath];
    [task setArguments: arguments];
    [task launch];
    [task waitUntilExit];

    int exitStatus = [task terminationStatus];
    if(exitStatus == 0) {
        NSLog(@"Exited successful. :+1:.");
    } else if(exitStatus == 2) {
      NSLog(@"Probably failed to post to djcharts.io");
    } else if(exitStatus == 3) {
        NSLog(@"No new traktor archive files found.");
    } else {
      NSLog(@"Exited with %d", [task terminationStatus]);
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *destinationURL = [[[NSProcessInfo processInfo]environment]objectForKey:@"HOME"];
    NSString *token = [[url componentsSeparatedByString:@"/"] objectAtIndex:2];

    NSError *writeError = nil;

    destinationURL = [destinationURL stringByAppendingString:@"/.traktor-charts"];
    NSLog(@"%@ - %@", destinationURL, token);
    [token writeToFile:destinationURL atomically:YES encoding:NSUTF8StringEncoding error:&writeError];

    NSLog(@"%@", writeError.localizedFailureReason);
}

@end
