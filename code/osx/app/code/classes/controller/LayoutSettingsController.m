/* See bottom of file for license and copyright information */

#import "LayoutSettingsController.h"
#import "MyDocument.h"
#import "interfacestrings.h"
#import "MyPathCell.h"

@implementation LayoutSettingsController

@synthesize usesDefaults;

- (void)awakeFromNib
{
	templateCssPathCell = [[[MyPathCell alloc] init] retain];
	templateJsDirectoryPathCell = [[[MyPathCell alloc] init] retain];
	templateFmPathCell = [[[MyPathCell alloc] init] retain];
	[self updateUsesDefaults];
}

- (void)dealloc
{
	[usesDefaults release];
	[templateCssPathCell release];
	[templateJsDirectoryPathCell release];
	[templateFmPathCell release];
	[super dealloc];
}

- (IBAction)showSettingsWindow:(id)sender
{	
	[oSettingsTable reloadData];
	[oSettingsWindow center];
	[oSettingsWindow makeKeyAndOrderFront:self];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return 4;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex
{	
	if ([[aTableColumn identifier] isEqualToString:@"key"]) {
		if (rowIndex == 0) return @"CSS template directory";
		if (rowIndex == 1) return @"JavaScript template directory";
		if (rowIndex == 2) return @"Freemarker template file";
		if (rowIndex == 3) return @"Document encoding";

	}
	if ([[aTableColumn identifier] isEqualToString:@"value"]) {
		NSString* value;
		if (rowIndex == 0) value = [[delegate settings] objectForKey:@"templateCssDirectory"];
		if (rowIndex == 1) value = [[delegate settings] objectForKey:@"templateJsDirectory"];
		if (rowIndex == 2) value = [[delegate settings] objectForKey:@"templateFreeMarker"];
		if (rowIndex == 3) value = [[delegate settings] objectForKey:@"docencoding"];
		return [NSURL URLWithString:value];
	}
	return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{		
	if (!anObject) return;
	
	if ([[tableColumn identifier] isEqualToString:@"value"]) {
		NSString* key;
		if (rowIndex == 0) key = @"templateCssDirectory";
		if (rowIndex == 1) key = @"templateJsDirectory";
		if (rowIndex == 2) key = @"templateFreeMarker";
		if (rowIndex != 3) {
			[[delegate settings] setObject:[self cleanupUrl:[anObject absoluteString]] forKey:key];
			return;
		}
		if (rowIndex == 3) {
			key = @"docencoding";
			[[delegate settings] setObject:anObject forKey:key];
			return;
		}
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id cell = [tableColumn dataCellForRow:rowIndex];
		
	if ([[tableColumn identifier] isEqualToString:@"key"]) {
		float GRAY = 0.95;
		[cell setBackgroundColor:[NSColor colorWithDeviceRed:GRAY green:GRAY blue:GRAY alpha:1.0]];
		[cell setDrawsBackground:YES];
	}
	
	if ([[tableColumn identifier] isEqualToString:@"value"]) {
		if (rowIndex == 0) return templateCssPathCell;
		if (rowIndex == 1) return templateJsDirectoryPathCell;
		if (rowIndex == 2) return templateFmPathCell;
	}
	return cell;
}

- (IBAction)restoreToDefaultValues:(id)sender
{
	[self setToValues:[delegate defaultSettings]];
}

- (void)setToValues:(NSDictionary*)dictionary
{
	[[delegate settings] setObject:[dictionary objectForKey:@"templateCssDirectory"] forKey:@"templateCssDirectory"];
	[[delegate settings] setObject:[dictionary objectForKey:@"templateJsDirectory"] forKey:@"templateJsDirectory"];
	[[delegate settings] setObject:[dictionary objectForKey:@"templateFreeMarker"] forKey:@"templateFreeMarker"];
	[[delegate settings] setObject:[dictionary objectForKey:@"docencoding"] forKey:@"docencoding"];
	[oSettingsTable reloadData];
}

- (IBAction)importSettings:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setResolvesAliases:YES];
	[openPanel setPrompt:IFACE_SELECT];
	NSArray* validFileExtensions = [NSArray arrayWithObjects:@"plist", nil];
	
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                                types:validFileExtensions
                       modalForWindow:oSettingsWindow
                        modalDelegate:self
                       didEndSelector:@selector(importPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)importPanelDidEnd:(NSOpenPanel*)sheet
			   returnCode:(int)returnCode
			  contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton) {
		NSArray* paths = [sheet filenames];
		if (paths != nil) {
			NSDictionary* importSettings = [NSDictionary dictionaryWithContentsOfFile:[paths objectAtIndex:0]];
			if (importSettings) {
				[self setToValues:importSettings];	
			}
		}
	}
}

- (IBAction)exportSettings:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:@"plist"];
	[panel setCanCreateDirectories:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
		BOOL success = [[self settings] writeToFile:[panel filename] atomically:YES];
		if (!success) {
			NSRunAlertPanel(@"Error saving", @"Could not save settings", @"OK", nil, nil);
		}
    }
}

- (NSDictionary*)settings
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[[delegate settings] objectForKey:@"templateCssDirectory"], @"templateCssDirectory",
		[[delegate settings] objectForKey:@"templateJsDirectory"], @"templateJsDirectory",
		[[delegate settings] objectForKey:@"templateFreeMarker"], @"templateFreeMarker",
		[[delegate settings] objectForKey:@"docencoding"], @"docencoding",
		nil];
}

- (NSString*)cleanupUrl:(NSString*)inUrl 
{
	NSString* cleanUrl = [inUrl stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
	return cleanUrl;
}

- (BOOL)hasDefaultSettings
{
	if (![self compareCurrentWithDefaultUrl:@"templateCssDirectory"]) return NO;
	if (![self compareCurrentWithDefaultUrl:@"templateJsDirectory"]) return NO;
	if (![self compareCurrentWithDefaultUrl:@"templateFreeMarker"]) return NO;
	if (![self compareCurrentWithDefaultValue:@"docencoding"]) return NO;

	return YES;
}

- (BOOL)compareCurrentWithDefaultUrl:(NSString*)key
{
	id value = [[delegate settings] objectForKey:key];
	if ([value isMemberOfClass:[NSURL class]]) {
		value = [value relativeString];
	}
	return [value isEqualToString:[[delegate defaultSettings] objectForKey:key]];
}

- (BOOL)compareCurrentWithDefaultValue:(NSString*)key
{
	id value = [[delegate settings] objectForKey:key];
	return [value isEqualToString:[[delegate defaultSettings] objectForKey:key]];
}

- (void)updateUsesDefaults
{
	[self setUsesDefaults:[NSNumber numberWithBool:[self hasDefaultSettings]]];
}

@end

/*
 VisDoc - Code documentation generator, http://visdoc.org
 This software is licensed under the MIT License
 
 The MIT License
 
 Copyright (c) 2010 Arthur Clemens, VisDoc contributors
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


