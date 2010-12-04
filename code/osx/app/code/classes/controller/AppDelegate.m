/* See bottom of file for license and copyright information */

#import "AppDelegate.h"
#import "MyDocument.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{	
	// open documents that were open on last quit
	NSData* openDocumentsAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"openDocumentUrls"];
	if (!openDocumentsAsData) return;
	
	NSArray* documentsUrls = [NSKeyedUnarchiver	unarchiveObjectWithData:openDocumentsAsData];
	if (!documentsUrls) return;
		
	// prevent duplicates
	NSMutableSet* openDocuments = [[[NSMutableSet alloc] init] autorelease];
	NSEnumerator* e = [documentsUrls objectEnumerator];
	NSURL* url = nil;
	while (url = [e nextObject]) {
		if (![openDocuments containsObject:url]) {
			[self _newDocumentWithUrl:url];
			[openDocuments addObject:url];
		}
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// remove currently stored documents
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"openDocumentUrls"];
	
	// store current open documents
	NSArray* openDocuments = [NSApp orderedDocuments];
	NSMutableArray* openDocumentUrls = [[[NSMutableArray alloc] initWithCapacity:[openDocuments count]] autorelease];
	NSEnumerator* e = [openDocuments reverseObjectEnumerator];
	NSDocument* d = nil;
	while (d = [e nextObject]) {
		NSURL* url = [d fileURL];
		if (url) {
			[openDocumentUrls addObject:url];
		}
	}
	if ([openDocumentUrls count]) {
		NSData *openDocumentsAsData = [NSKeyedArchiver archivedDataWithRootObject:openDocumentUrls];
		[[NSUserDefaults standardUserDefaults] setObject:openDocumentsAsData forKey:@"openDocumentUrls"];
	}

	return NSTerminateNow;
}

- (void)dealloc
{
	[super dealloc];
}

- (IBAction)orderFrontStandardAboutPanel:(id)sender
{
	NSImage* img = [NSImage imageNamed:@"VisDoc"];
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"Version",
							 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"], @"ApplicationName",
							 img, @"Image",
							 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"VAVDCopyright"], @"Copyright",
							 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"ApplicationVersion",
							 nil];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

- (void)_newDocumentWithUrl:(NSURL*)url
{
	MyDocument* newDocument = [[[MyDocument alloc] initWithContentsOfURL:url ofType:@"DocumentType" error:nil] autorelease];
	NSDocumentController *sharedDocController = [NSDocumentController sharedDocumentController];
	
	// set up the document
	if (newDocument) {
		// add the document
		[sharedDocController addDocument:newDocument];
		
		// set up the document
		if ([sharedDocController shouldCreateUI]) {
			[newDocument makeWindowControllers];
			[newDocument showWindows];
		}
	}
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

