/* See bottom of file for license and copyright information */

#import "PathInfo.h"

@implementation PathInfo

@synthesize path;
@synthesize validFileCount;
@synthesize isSelected;
@synthesize isDir;

static NSImage* sImageFolder;
static NSImage* sImageFolderInvalid;
static NSImage* sImageDocument;
static NSImage* sImageDocumentInvalid;
static NSImage* sImageInProgress;

+ (void)initialize {
	NSString* path;
	path = [[NSBundle mainBundle] pathForResource:@"folder" ofType:@"png"];
	sImageFolder = [[[NSImage alloc] initWithContentsOfFile:path] retain];
	
	path = [[NSBundle mainBundle] pathForResource:@"folder_invalid" ofType:@"png"];
	sImageFolderInvalid = [[[NSImage alloc] initWithContentsOfFile:path] retain];
	
	path = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"png"];
	sImageDocument = [[[NSImage alloc] initWithContentsOfFile:path] retain];
	
	path = [[NSBundle mainBundle] pathForResource:@"document_invalid" ofType:@"png"];
	sImageDocumentInvalid = [[[NSImage alloc] initWithContentsOfFile:path] retain];
	
	path = [[NSBundle mainBundle] pathForResource:@"in_progress" ofType:@"png"];
	sImageInProgress = [[[NSImage alloc] initWithContentsOfFile:path] retain];
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeObject:[self path] forKey:@"path"];
    [coder encodeInt:[self validFileCount] forKey:@"validFileCount"];
    [coder encodeBool:[self isSelected] forKey:@"isSelected"];
    [coder encodeBool:[self isDir] forKey:@"isDir"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
	if ((self=[super init])) {
		[self setPath:[coder decodeObjectForKey:@"path"]];
		[self setValidFileCount:[coder decodeIntForKey:@"validFileCount"]];
		[self setIsSelected:[coder decodeBoolForKey:@"isSelected"]];
		[self setIsDir:[coder decodeBoolForKey:@"isDir"]];
	}
    return self;
}

- (id)initWithPath:(NSString*)inPath
{
    self = [super init];
    if (self) {
		[self setPath:inPath];
		[self setValidFileCount:-1]; // not counted yet
		[self setIsSelected:YES];
		[self setIsDir:NO];
	}
	return self;
}

- (void)dealloc
{
	[path release];
	[super dealloc];
}

- (BOOL)isValidAndSelected
{
	return (validFileCount > 0 && isSelected); 	
}

- (BOOL)isSelected
{
	if (validFileCount == 0) return NO;
	return isSelected;
}

- (NSColor*)textColor
{
	return (validFileCount > 0) ? [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1.0] : [NSColor colorWithDeviceRed:.83 green:.82 blue:.85 alpha:1.0];
}

- (NSImage*)icon
{	
	if (validFileCount == -1) {
		return sImageInProgress;	
	}
	if (isDir) {
		return validFileCount ? sImageFolder : sImageFolderInvalid;
	}
	if (!isDir) {
		return validFileCount ? sImageDocument : sImageDocumentInvalid;
	}
	return nil;
}

- (void)revealInFinder
{
	[[NSWorkspace sharedWorkspace] selectFile:path
					 inFileViewerRootedAtPath:nil];
}

- (NSString*)description
{
    NSMutableString* outText = [[[NSMutableString alloc] init] autorelease];
    [outText appendString:@"(PathInfo)"];
    [outText appendString:[NSString stringWithFormat:@"\n\t path = %@", [self path]]];
    [outText appendString:[NSString stringWithFormat:@"\n\t validFiles = %d", [self validFileCount]]];
    [outText appendString:[NSString stringWithFormat:@"\n\t isSelected = %d", [self isSelected]]];
    [outText appendString:[NSString stringWithFormat:@"\n\t isDir = %d", [self isDir]]];
    return outText;
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


