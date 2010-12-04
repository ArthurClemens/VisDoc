/* See bottom of file for license and copyright information */

#import "SimplePerlBridge.h"

static NSString* DATAPATH = @"/private/tmp/perlToVisDoc.txt";


@implementation SimplePerlBridge

@synthesize task;

- (void)dealloc
{
	if ([task isRunning]) {
		[task terminate];	
	}
	[task release];
	task = nil;
	[super dealloc];
}

/**
Calls a perl script with an argument list and returns the output.
*/
- (NSString*)runScript:(NSString*)scriptPath argumentList:(NSArray*)argumentList
{
	return [self runScript:scriptPath argumentList:argumentList readFromFile:NO];
}

- (NSString*)runScript:(NSString*)scriptPath argumentList:(NSArray*)argumentList readFromFile:(BOOL)readFromFile
{	
	NSTask* theTask = [[NSTask alloc] init];
	[self setTask:theTask];
	NSString* taskOutput = nil;
	if (readFromFile) {
		argumentList = [argumentList arrayByAddingObject:@"-datapath"];
		argumentList = [argumentList arrayByAddingObject:DATAPATH];
	}
	argumentList = [argumentList arrayByAddingObject:@"-feedback"];
	argumentList = [argumentList arrayByAddingObject:@"1"];
	
    [task setLaunchPath:scriptPath];
	[task setCurrentDirectoryPath:[scriptPath stringByDeletingLastPathComponent]];
	[task setStandardOutput:[NSPipe pipe]];
	if (argumentList) {
		[task setArguments:argumentList];
	}
	
    [task launch];
	[task waitUntilExit]; // wait for the task to finish before continuing!
	if (readFromFile) {
		taskOutput = [NSString stringWithContentsOfFile:DATAPATH encoding:NSUTF8StringEncoding error:nil];
		//[@"" writeToFile:DATAPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
	} else {
		taskOutput = [[NSString alloc] initWithData:[[[task standardOutput] fileHandleForReading] availableData] encoding:NSUTF8StringEncoding];
	}
	[self setTask:nil];
	return taskOutput;
}

/**
Helper function to facilitate Perl string => Cocoa object communication.
Creates a NSDictionary property list object from a string. The string must have a valid property list format.
*/
+ (NSDictionary*)propertyListFromString:(NSString*)inText
{
	if (![inText isValidString]) {
		return nil;	
	}
	NSData* data = [inText dataUsingEncoding:NSUTF8StringEncoding];
	NSString *errorString = nil;
	NSPropertyListFormat format;
	NSDictionary* dict = [NSPropertyListSerialization propertyListFromData:data
														  mutabilityOption:0
																	format:&format
														  errorDescription:&errorString];
	
	NSAssert1 (dict, @"propertyListFromString -- could not create property list: %@", inText);
	return dict;
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


