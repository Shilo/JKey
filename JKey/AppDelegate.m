//
//  AppDelegate.m
//  JKey
//
//  Created by Shilo White on 2/1/15.
//  Copyright (c) 2015 Shilocity. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate {
    NSStatusItem *_statusItem;
    NSAppleScript *_appleScript;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _appleScript = [[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" to keystroke \"j\""];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem sendActionOn:NSLeftMouseDownMask];
    _statusItem.title = @"J";
    _statusItem.highlightMode = YES;
    _statusItem.target = self;
    _statusItem.action = @selector(inputJKey);
}

- (void)inputJKey {
    [_appleScript executeAndReturnError:nil];
}

@end
