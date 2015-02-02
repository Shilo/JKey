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
    NSString *_keyStroke;
    NSMenuItem *_keyStrokeMenuItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _keyStroke = KEYSTROKE;
    _appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" to keystroke \"%@\"", _keyStroke]];
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSString *uppercaseKeyStroke = [_keyStroke uppercaseString];
    
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
    _keyStrokeMenuItem = [_menu insertItemWithTitle:[NSString stringWithFormat:@"Keystroke: %@", _keyStroke] action:@selector(onChangeKeyStroke) keyEquivalent:@"" atIndex:0];
    [_menu insertItemWithTitle:@"Quit" action:@selector(onQuit) keyEquivalent:@"" atIndex:1];
}

- (void)onChangeKeyStroke {
    NSString *keyStroke = [self input:@"Change keystroke value:" defaultValue:_keyStroke];
    if (keyStroke && ![keyStroke isEqualToString:_keyStroke]) {
        [self changeKeyStroke:keyStroke];
    }
}

- (void)changeKeyStroke:(NSString *)keyStroke {
    _keyStroke = keyStroke;
    _appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" to keystroke \"%@\"", _keyStroke]];
    NSString *uppercaseKeyStroke = [_keyStroke uppercaseString];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        _statusItem.button.title = uppercaseKeyStroke;
    } else {
        _statusItem.title = uppercaseKeyStroke;
    }
    
    _menu.title = uppercaseKeyStroke;
    _keyStrokeMenuItem.title = [NSString stringWithFormat:@"Keystroke: %@", _keyStroke];
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
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
