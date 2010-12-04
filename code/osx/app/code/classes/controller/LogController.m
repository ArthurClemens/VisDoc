/* See bottom of file for license and copyright information */

#import "LogController.h"
#import "StringAdditions.h"

@implementation LogController

- (void)processLogResults:(NSString*)processResult
{
	if (!processResult) return;
		
	NSArray* lines = [processResult componentsSeparatedByString:@"\n"];
	if (![lines count] > 0) return;
	
	[self writeDate];
 	[self writeString:@"Processed:"];
	
	NSString *regex = @"^PARSED#(.*)";
	NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	NSEnumerator* e = [lines objectEnumerator];
	NSString* line = nil;
	while (line = [e nextObject]) {
		if ([regexTest evaluateWithObject:line] == YES) {
			NSArray* parts = [line componentsSeparatedByString:@"#"];
			if ([parts objectAtIndex:1] && [parts objectAtIndex:2] ) {
				[self logAttString:[self createLink:[parts objectAtIndex:1] path:[parts objectAtIndex:2]]];
				[self logAttString:[self formatNewline]];
			}
		}
	}	
}

- (void)processErrorResults:(NSString*)logString
{
	if (!logString) return;
	[self writeDate];
	[self logAttString:[self formatErrorText:@"An error occurred during processing:\n"]];
	[self writeString:logString];
}

- (NSAttributedString*)createLink:(NSString*)label path:(NSString*)path
{
    if (![path isValidString] || ![label isValidString]) {
        return nil;
    }
    NSMutableDictionary *linkAttributes = nil;
	
    NSString* linkToFileString = [NSString stringWithFormat:@"file://%@", path];
	
    linkAttributes = [NSMutableDictionary dictionaryWithObject:linkToFileString
														forKey:NSLinkAttributeName];
	[linkAttributes setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
	[linkAttributes setObject:[NSNumber numberWithBool:YES]  forKey:NSUnderlineStyleAttributeName];
	NSAttributedString* link = [[[NSAttributedString alloc] initWithString:label
																attributes:linkAttributes] autorelease];
	return link;
}

- (NSAttributedString*)formatErrorText:(NSString*)inText
{
	NSDictionary* colorAttr = [NSDictionary dictionaryWithObject:[NSColor redColor]
														  forKey:NSForegroundColorAttributeName];
	NSAttributedString* formattedString = [[[NSAttributedString alloc] initWithString:inText
																		   attributes:colorAttr] autorelease];
	return formattedString;
}

- (NSAttributedString*)formatGrayText:(NSString*)inText
{
	NSDictionary* colorAttr = [NSDictionary dictionaryWithObject:[NSColor grayColor]
														  forKey:NSForegroundColorAttributeName];
	NSAttributedString* formattedString = [[[NSAttributedString alloc] initWithString:inText
																		   attributes:colorAttr] autorelease];
	return formattedString;
}

- (NSAttributedString*)formatNewline
{
	NSString* text = @"\n";
	NSAttributedString* formattedString = [[[NSAttributedString alloc] initWithString:text] autorelease];
	return formattedString;
}

- (NSAttributedString*)formatString:(NSString*)logString
{
	return [[[NSAttributedString alloc] initWithString:logString] autorelease];
}

- (void)clearLog
{
	[oLogView setString:@""];
}

- (void)writeString:(NSString*)logString
{
	[self logAttString:[self formatString:logString]];
	[self logAttString:[self formatNewline]];
}

- (void)writeDate
{
	NSCalendarDate* calDate = [[NSDate date] dateWithCalendarFormat:@"%A, %d %B %Y, %H:%M:%S"
													timeZone:[NSTimeZone localTimeZone]];
	NSString* dateString = [NSString stringWithFormat:@"%@", calDate];
	[self logAttString:[self formatGrayText:dateString]];
	[self logAttString:[self formatNewline]];
}

- (void)logAttString:(NSAttributedString*)inText
{	
	NSMutableAttributedString* text = [[[NSMutableAttributedString alloc] init] autorelease];
	[text setAttributedString:inText];
	NSMutableDictionary *textAttributes = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	NSMutableParagraphStyle* spacedLinesStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[spacedLinesStyle setParagraphStyle: [NSParagraphStyle defaultParagraphStyle]];
	[spacedLinesStyle setLineSpacing:2.0];
	[textAttributes setObject:spacedLinesStyle forKey:NSParagraphStyleAttributeName];
	NSRange range = NSMakeRange(0, [text length]);
    [text addAttributes:textAttributes range:range];
	
	[[oLogView textStorage] appendAttributedString:text];
	NSFont* font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
	[oLogView setFont:font];
	
	[self scrollViewToBottom];
}

- (void)scrollViewToBottom
{
	NSRange range;	
	range.location = [[oLogView textStorage] length];
	range.length = 0;
	[oLogView scrollRangeToVisible:range];
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


