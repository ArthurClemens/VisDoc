/* See bottom of file for license and copyright information */

#import "DragDropTextField.h"
#import "StringAdditions.h"

@implementation DragDropTextField

- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

 - (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
 {
	 NSPasteboard *pboard;
	 NSDragOperation sourceDragMask;
	 sourceDragMask = [sender draggingSourceOperationMask];
	 pboard = [sender draggingPasteboard];
	 NSEnumerator* pboardEnumerator = [[pboard types] objectEnumerator];
	 NSString* type;
	 while((type = [pboardEnumerator nextObject])) {
		 if ([type isEqualToString:NSFilenamesPboardType]) {
			 NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
			 NSString* path = [files objectAtIndex:0];
			 NSError* error;
			 NSDictionary *fattrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
			 if (fattrs) {
				 // path is correct
				 NSString *fileType = [fattrs objectForKey:NSFileType];
				 if ([fileType isEqualToString:NSFileTypeDirectory]) {
					 if (sourceDragMask & NSDragOperationLink) {
						 return NSDragOperationLink;
					 } else if (sourceDragMask & NSDragOperationCopy) {
						 return NSDragOperationCopy;
					 }					 
				 }
			 }
		 }
	 }
	 return NSDragOperationNone;
 }
 
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		NSString* path = [files objectAtIndex:0];
		path = [path resolveAlias];
		SEL selector = @selector(setOutDirectory:);
		id target = [self delegate];
		[target performSelector:selector withObject:path];
	}
	return YES;
}
 
 - (void)draggingExited:(id <NSDraggingInfo>)sender
{
	//
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if (![[self stringValue] isValidString]) return;
	if ([theEvent clickCount] > 1) {
		[[NSWorkspace sharedWorkspace] selectFile:[self stringValue]
						 inFileViewerRootedAtPath:nil];
		
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

