//
//  AppDelegate.m
//  JKey
//
//  Created by Shilo White on 2/1/15.
//  Copyright (c) 2015 Shilocity. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

@interface NSStatusBarButton (RightClick)

@property SEL rightAction;

@end

@implementation NSStatusBarButton (RightClick)

@dynamic rightAction;

- (SEL)rightAction {
    return [objc_getAssociatedObject(self, @selector(rightAction)) pointerValue];
}

- (void)setRightAction:(SEL)_rightAction {
    objc_setAssociatedObject(self, @selector(rightAction), [NSValue valueWithPointer:_rightAction], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [self sendAction:self.rightAction to:self.target];
    [super rightMouseDown:theEvent];
}

@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate {
    NSStatusItem *_statusItem;
    NSAppleScript *_appleScript;
    NSMenu *_menu;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _appleScript = [[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" to keystroke \"j\""];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.title = @"J";
    _statusItem.button.target = self;
    _statusItem.button.action = @selector(onLeftClick);
    _statusItem.button.rightAction = @selector(onRightClick);
    
    _menu = [[NSMenu alloc] initWithTitle:@"J"];
    [_menu insertItemWithTitle:@"Quit" action:@selector(onQuit) keyEquivalent:@"" atIndex:0];
}

- (void)onLeftClick {
    [_appleScript executeAndReturnError:nil];
}

- (void)onRightClick {
    _statusItem.menu = _menu;
    [_statusItem.button performClick:self];
    _statusItem.menu = nil;
}

- (void)onQuit {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0];
}

@end
