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


    _statusItem.title = @"DJCharts";
    _statusItem.image = [NSImage imageNamed:@"status-item2"];
    _statusItem.highlightMode = YES;
    
    // The highlighted image, use a white version of the normal image
    // _statusItem.alternateImage = [NSImage imageNamed:@"feedbin-logo-alt"];


    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Open DJ Charts" action:@selector(openDJCharts:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Update" action:@selector(refreshDJCharts:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}

- (void)openDJCharts:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://djcharts.io/"]];
}

- (void)refreshDJCharts:(id)sender {
    NSTask *task;
    NSArray *arguments = [NSArray arrayWithObject: @"hi atmos"];

    task = [[NSTask alloc]init];
    [task setLaunchPath: @"/Users/atmos/traktor-charts/bin/traktor-charts"];
    [task setArguments: arguments];
    [task launch];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
