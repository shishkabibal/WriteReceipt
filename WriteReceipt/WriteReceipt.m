//
//  WriteReceipt.m
//  WriteReceipt
//
//  Created by Brian "Shishkabibal" on 4/26/18.
//  Copyright (c) 2018 Brian "Shishkabibal". All rights reserved.
//

// Imports

@import AppKit;
#import "ZKSwizzle.h"

// Interfaces

@interface WriteReceipt : NSObject
@end

@interface UnifiedChatListViewController : NSViewController
- (void)markAsRead:(id)arg1;
@end

@interface NSUserNotificationCenter (Private)
- (void)_removeDisplayedNotification:(id)arg1;
@end

// Variables

WriteReceipt* plugin;
UnifiedChatListViewController* unifiedChatListViewController;
BOOL keyPressed;

// WriteReceipt

@implementation WriteReceipt

+ (WriteReceipt*) sharedInstance {
	static WriteReceipt* plugin = nil;
	
	if (plugin == nil)
		plugin = [[WriteReceipt alloc] init];
	
	return plugin;
}

+(void)load {
	NSLog(@"WriteReceipt: Plugin Loaded");
	
	plugin = [WriteReceipt sharedInstance];
}
	
@end

// ZKSwizzleInterfaces

ZKSwizzleInterface(BSUnifiedChatWindowController, UnifiedChatWindowController, NSWindowController)
@implementation BSUnifiedChatWindowController

// Required because `[ChatController markAllMessagesAsRead]` used to handle this
- (void)userNotificationCenter:(id)arg1 didActivateNotification:(id)arg2 {
	[arg1 _removeDisplayedNotification:arg2];
	ZKOrig(void, arg1, arg2);
}

@end

ZKSwizzleInterface(BSUnifiedChatListViewController, UnifiedChatListViewController, NSViewController)
@implementation BSUnifiedChatListViewController

// Reqired to call `[UnifiedChatListViewController markAsRead:arg1]` from `SOInputLine`
- (void)viewDidAppear {
	NSLog(@"WriteReceipt: Hooked UnifiedChatListViewController");
	
	unifiedChatListViewController = (UnifiedChatListViewController*)self;
	
	ZKOrig(void);
}

@end

ZKSwizzleInterface(BSChatController, ChatController, NSObject)
@implementation BSChatController

// Block `[ChatController markAllMessagesAsRead]` unless `keyPressed`
- (void)markAllMessagesAsRead {
	if (keyPressed) {
		NSLog(@"WriteReceipt: Modified markAllMessagesAsRead");
		
		keyPressed = NO;
		
		ZKOrig(void);
	} else {
		NSLog(@"WriteReceipt: Blocked markAllMessagesAsRead");
	}
}

@end

ZKSwizzleInterface(BSSOInputLine, SOInputLine, NSTextView)
@implementation BSSOInputLine

// Initiate `[unifiedChatListViewController markAsRead:arg1]` with `keyPressed`
- (void)keyDown:(id)arg1 {
	NSLog(@"WriteReceipt: Modified keyDown");
	
	keyPressed = YES;
	[unifiedChatListViewController markAsRead:arg1];
	
	ZKOrig(void, arg1);
}

@end
