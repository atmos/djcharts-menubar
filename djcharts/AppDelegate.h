//
//  AppDelegate.h
//  djcharts
//
//  Created by Corey Donohoe on 12/9/14.
//  Copyright (c) 2014 Corey Donohoe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Squirrel/Squirrel.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;

@property (strong, nonatomic) SQRLUpdater *updater;

@property (strong, nonatomic) NSMenuItem *menuItemUpdate;
@property (strong, nonatomic) NSMenuItem *menuItemConfiguration;

@end

