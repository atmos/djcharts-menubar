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
    [menu addItemWithTitle:@"Open djcharts.io" action:@selector(openDJCharts:) keyEquivalent:@""];

    self.menuItemConfiguration = [menu addItemWithTitle:@"Setup" action:@selector(openDJChartsConfiguration:) keyEquivalent:@""];
    self.menuItemUpdate = [menu addItemWithTitle:@"Sync Now" action:@selector(refreshDJCharts:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];

    _statusItem.menu = menu;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                  target: self
                  selector:@selector(onPulse:)
                  userInfo: nil repeats:YES];

    NSURLComponents *components = [[NSURLComponents alloc] init];

    components.scheme = @"https";
    components.host = @"djcharts.io";
    components.path = @"/api/macapp";

    NSString *bundleVersion = NSBundle.mainBundle.sqrl_bundleVersion;
    components.query = [[NSString stringWithFormat:@"version=%@", bundleVersion] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

    self.updater = [[SQRLUpdater alloc] initWithUpdateRequest:[NSURLRequest requestWithURL:components.URL]];

    [self.updater.updates subscribeNext:^(SQRLDownloadedUpdate *downloadedUpdate) {
        NSLog(@"An update is ready to install: %@", downloadedUpdate);
        [[NSApplication sharedApplication] terminate:nil];
    }];

    [[self.updater relaunchToInstallUpdate] subscribeError:^(NSError *error) {
        NSLog(@"Error preparing update: %@", error);
    }];

    // Check for updates every 4 hours.
    [self.updater startAutomaticChecksWithInterval:30];

    [self updateLocalData];
    timer = nil; // lol
}

- (void)openDJCharts:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://djcharts.io/"]];
}

- (void)openDJChartsConfiguration:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://djcharts.io/settings/configure"]];
}

- (void)updateLocalData {
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
        self.menuItemUpdate.hidden = NO;
        self.menuItemConfiguration.hidden = YES;

        NSLog(@"Exited successful. :+1:.");
    } else if(exitStatus == 1) {
        self.menuItemUpdate.hidden = NO;
        self.menuItemConfiguration.hidden = YES;

        NSLog(@"No new traktor archive files found.");
    } else if(exitStatus == 2) {
        self.menuItemUpdate.hidden = YES;
        self.menuItemConfiguration.hidden = NO;

        NSLog(@"Probably failed to post to djcharts.io");
    } else {
        NSLog(@"Exited with %d", [task terminationStatus]);
    }
}

- (void)onPulse:(NSTimer *)timer {
  NSLog(@"Periodic Pulse.");

  [self updateLocalData];
}

- (void)refreshDJCharts:(id)sender {
    [self updateLocalData];
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

    if(writeError.localizedFailureReason != NULL) {
      NSLog(@"%@", writeError.localizedFailureReason);
    }
    [self updateLocalData];
}


@end
