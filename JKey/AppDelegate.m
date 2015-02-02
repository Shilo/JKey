//
//  AppDelegate.m
//  JKey
//
//  Created by Shilo White on 2/1/15.
//  Copyright (c) 2015 Shilocity. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

#define KEYSTROKE @"j"

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
    _appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" to keystroke \"%@\"", KEYSTROKE]];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSString *uppercaseKeyStroke = [KEYSTROKE uppercaseString];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        _statusItem.button.title = uppercaseKeyStroke;
        _statusItem.button.target = self;
        _statusItem.button.action = @selector(onLeftClick:);
        _statusItem.button.rightAction = @selector(onRightClick:);
    } else {
        _statusItem.title = uppercaseKeyStroke;
        _statusItem.target = self;
        _statusItem.action = @selector(onLeftClick:);
        _statusItem.highlightMode = YES;
    }
    
    _menu = [[NSMenu alloc] initWithTitle:uppercaseKeyStroke];
    [_menu insertItemWithTitle:@"Quit" action:@selector(onQuit) keyEquivalent:@"" atIndex:0];
}

- (void)onLeftClick:(NSStatusBarButton *)button {
    NSEvent *event = [NSApp currentEvent];
    NSEventModifierFlags modifierFlags = event.modifierFlags;
    if((modifierFlags & NSCommandKeyMask) || (modifierFlags & NSControlKeyMask)) {
        [self onRightClick:button];
    } else {
        [_appleScript executeAndReturnError:nil];
    }
}

- (void)onRightClick:(NSStatusBarButton *)button {
    _statusItem.menu = _menu;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [_statusItem.button performClick:self];
    } else {
        [button performClick:self];
    }
    _statusItem.menu = nil;
}

- (void)onQuit {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0];
}

@end
