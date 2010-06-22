//
//  ArchiveMailBundle.m
//  ArchivePlugin
//
//  Created by Donald Ephraim Curtis on 6/17/10.
//  Copyright 2010 University of Iowa. All rights reserved.
//

#import "ArchiveMailBundle.h"
#import </usr/include/objc/objc-class.h>

@implementation ArchiveMailBundle

+ (void) initialize
{
	[super initialize];
	
//	class_setSuperclass([self class], NSClassFromString(@"MVMailBundle"));
//	[ArchiveMailBundle registerBundle];
	

//	[[self alloc] init];

	// Add a couple methods to the MessageViewer class.
	Class MessageViewer = NSClassFromString(@"MessageViewer");
	[[self class] copyMethod:@selector(_specialValidateMenuItem:) fromClass:[self class] toClass:MessageViewer];
	[[self class] copyMethod:@selector(archiveSelectedMessages:) fromClass:[self class] toClass:MessageViewer];
	
	// Swizzle the methods so our validate function gets called.
	[[self class] swizzleMethod:@selector(validateMenuItem:) withMethod:@selector(_specialValidateMenuItem:) inClass:MessageViewer];
	
	// Find the "Message" menu.
	NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
	NSArray *mainMenuItems = [mainMenu itemArray];
	
	NSMenuItem *messageMenu = nil;
	for(int i=0; i < [mainMenuItems count]; i++)
	{
		if ([[[mainMenuItems objectAtIndex:i] title] isEqual:@"Message"]) {
			messageMenu = [mainMenuItems objectAtIndex:i];
		}
	}
	
	if (messageMenu == nil) {
		NSLog(@"Failed to find Message Menu");
		return;
	}
	
	// Add our menu entry.
	NSMenu *messageSubMenu = [messageMenu submenu];
	NSMenuItem *menuItem = [messageSubMenu insertItemWithTitle:@"Archive Selected Messages" action:@selector(archiveSelectedMessages:) keyEquivalent:@"e" atIndex:9];
	[menuItem setKeyEquivalentModifierMask:NSControlKeyMask];
	
	NSLog(@"ArchiveMail Plugin Loaded.");
	
}


- (IBAction) archiveSelectedMessages:(id)sender
{
	// Get the selected messages
	NSMutableArray *selMsgs = [self selectedMessages];

	for (int i=0; i < [selMsgs count]; i++) {
		NSObject *msg = [selMsgs objectAtIndex:i];
		NSMutableArray *allMbx = [[msg account] allMailboxUids];
		
		// Look for an "Archive" folder.
		for (int j=0; j< [allMbx count]; j++) {
			// Get the mailbox of the message we're looking at.
			NSObject *mbx = [allMbx objectAtIndex:j];
			if ([[mbx name] isEqual:@"Archive"]) {
				// We have to selected only the message we're interested in moving.
				// Each message may be in a different account.
				[[self tableManager] selectMessages:[NSArray arrayWithObject:msg]];
				// To do the move we have to generate an event from a menu item.
				NSObject *mi = [[NSMenuItem alloc] init];
				[mi setRepresentedObject:mbx];
				[self moveMessagesToMailbox:mi];
				[mi release];
				break;
			}
		}
	}
	
}

- (BOOL)_specialValidateMenuItem:(NSMenuItem *)item 
{
	// Our action is only valid if there are selected messages.
	
	if ([item action] == @selector(archiveSelectedMessages:))
	{
		NSMutableArray *selMsgs = [self selectedMessages];
		if ([selMsgs count] > 0) {
			return TRUE;
		}
		return FALSE;
	}
	return [self _specialValidateMenuItem:item];
}	

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel inClass:(Class)cls
{
	// For class (cls), swizzle the original selector with the new selector.
	Method origMethod = class_getInstanceMethod(cls, origSel);
	if (!origMethod) {
		NSLog(@"original method %@ not found for class %@", NSStringFromSelector(origSel), 
			  [cls className]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(cls, altSel);
	if (!altMethod) {
		NSLog(@"alternate method %@ not found for class %@", NSStringFromSelector(altSel), 
			  [cls className]);
		return NO;
	}
	
	method_exchangeImplementations(origMethod, altMethod);
	
	return YES;
	
}

+ (BOOL) copyMethod:(SEL)sel fromClass:(Class)fromCls toClass:(Class)toCls
{
	// copy a method from one class to another.
	Method method = class_getInstanceMethod(fromCls, sel);
	if (!method)
	{
		NSLog(@"method %@ could not be found in class %@", NSStringFromSelector(sel),
			  [fromCls className]);
		return NO;
	}
	class_addMethod(toCls, sel, 
					class_getMethodImplementation(fromCls, sel), 
					method_getTypeEncoding(method));
	return YES;
}

@end
