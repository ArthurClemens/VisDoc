/* See bottom of file for license and copyright information */

#import "StringAdditions.h"

@implementation NSString (StringAdditions)


- (BOOL)isValidString
{
    if (self != nil && [self length] > 0) {
        return YES;
	}
	// else
	return NO;
}

- (NSString *)trimWhitespace
{
	NSMutableString		* theString = [[self mutableCopy] autorelease];
	CFStringTrimWhitespace( (CFMutableStringRef)theString );
	
	return theString;
}

- (NSString*)resolveAlias
{	
	NSString *resolvedPath = nil;	
	CFURLRef url = CFURLCreateWithFileSystemPath (kCFAllocatorDefault, (CFStringRef)self, kCFURLPOSIXPathStyle, NO);
	if (url != NULL)
	{
		FSRef fsRef;
		if (CFURLGetFSRef(url, &fsRef))	
		{
			Boolean targetIsFolder, wasAliased;
			OSErr err = FSResolveAliasFile (&fsRef, true, &targetIsFolder, &wasAliased);
			if ((err == noErr) && wasAliased)	
			{		
				CFURLRef resolvedUrl = CFURLCreateFromFSRef(kCFAllocatorDefault, &fsRef);	
				if (resolvedUrl != NULL)		
				{		
					resolvedPath = (NSString*)	
					CFURLCopyFileSystemPath(resolvedUrl, kCFURLPOSIXPathStyle);	
					CFRelease(resolvedUrl);		
				}	
			}
		}
		CFRelease(url);	
	}

	if (resolvedPath == nil)
	{
		return self;
	}
	return resolvedPath;
}

- (NSString *)onlyKeepCharactersInSet:(NSCharacterSet*)characterSet
{
	NSString *result = nil;
	unsigned len = [self length];
	unichar *buffer = malloc(len * sizeof(unichar));
	unsigned i;
	unsigned j = 0;
	for ( i = 0 ; i < len ; i++ )
	{
		unichar c = [self characterAtIndex:i];
		if ([characterSet characterIsMember:c])
		{
			buffer[j++] = c;
		}
	}
	result = [[[NSString alloc] initWithCharacters:buffer length:j] autorelease];
	free(buffer);
	return result;
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


