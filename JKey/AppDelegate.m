//
//  AppDelegate.m
//  JKey
//
//  Created by Shilo White on 2/1/15.
//  Copyright (c) 2015 Shilocity. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#include <Carbon/Carbon.h>

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
    NSMenu *_menu;
    NSString *_keyStroke;
    NSMenuItem *_keyStrokeMenuItem;
    NSAlert *_alert;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _keyStroke = [self currentKeyStroke];
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

- (NSString *)currentKeyStroke {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *keyStroke = [userDefaults stringForKey:@"keystroke"];
    return (keyStroke.length ? keyStroke : KEYSTROKE);
}

- (void)onChangeKeyStroke {
    NSString *keyStroke = [self input:@"Change keystroke value:" defaultValue:_keyStroke];
    if (keyStroke && ![keyStroke isEqualToString:_keyStroke]) {
        [self changeKeyStroke:keyStroke];
    }
}

- (void)changeKeyStroke:(NSString *)keyStroke {
    _keyStroke = keyStroke;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_keyStroke forKey:@"keystroke"];
    [userDefaults synchronize];
    
    NSString *uppercaseKeyStroke = [_keyStroke uppercaseString];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        _statusItem.button.title = uppercaseKeyStroke;
    } else {
        _statusItem.title = uppercaseKeyStroke;
    }
    
    _menu.title = uppercaseKeyStroke;
    _keyStrokeMenuItem.title = [NSString stringWithFormat:@"Keystroke: %@", _keyStroke];
}

- (void)showKeyboard
{
    [self toggleKeyboard:YES];
    [[_alert accessoryView] becomeFirstResponder];
}

- (void)toggleKeyboard:(BOOL)show
{
    NSDictionary *property = [NSDictionary dictionaryWithObject:(NSString*)kTISTypeKeyboardViewer
                                                         forKey:(NSString*)kTISPropertyInputSourceType];
    NSArray *sources = (__bridge NSArray*)TISCreateInputSourceList((__bridge CFDictionaryRef)property, false);
    
    TISInputSourceRef keyboardViewer = (__bridge TISInputSourceRef)[sources objectAtIndex:0];
    if (show == YES)
    {
        TISSelectInputSource(keyboardViewer);
    }
    else
    {
        TISDeselectInputSource(keyboardViewer);
    }
    
    CFRelease((CFTypeRef)sources);
    
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"\u2328 Keyboard"
                                       otherButton:@"Cancel"
                         informativeTextWithFormat:@""];
    _alert = alert;
    
    NSButton *keyboardButton = [[alert buttons] objectAtIndex:2];
    [keyboardButton setTarget:self];
    [keyboardButton setAction:@selector(showKeyboard)];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[alert window] setInitialFirstResponder:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        [self toggleKeyboard:NO];
        _alert = nil;
        return [input stringValue];
    } else {
        [self toggleKeyboard:NO];
        _alert = nil;
        return nil;
    }
}

- (void)onLeftClick:(NSStatusBarButton *)button {
    NSEvent *event = [NSApp currentEvent];
    NSEventModifierFlags modifierFlags = event.modifierFlags;
    if((modifierFlags & NSCommandKeyMask) || (modifierFlags & NSControlKeyMask)) {
        [self onRightClick:button];
    } else {
        NSString *keyStroke = (modifierFlags & NSAlphaShiftKeyMask) ? [_keyStroke uppercaseString] : (modifierFlags & NSShiftKeyMask) ? [_keyStroke capitalizedString] : _keyStroke;
        for (int i = 0; i<keyStroke.length; i++) {
            CGEventRef keyEvent = CGEventCreateKeyboardEvent(NULL, 0, true);
            UniChar c = [keyStroke characterAtIndex:i];
            CGEventKeyboardSetUnicodeString(keyEvent, 1, &c);
            CGEventPost(kCGSessionEventTap, keyEvent);
            CFRelease(keyEvent);
        }
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
