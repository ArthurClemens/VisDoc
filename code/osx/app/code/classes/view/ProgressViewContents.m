/* See bottom of file for license and copyright information */

#import "ProgressViewContents.h"
#import "AMIndeterminateProgressIndicatorCell.h"

@implementation ProgressViewContents

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
	//[super mouseDown:theEvent];
}

- (void)awakeFromNib
{	
	AMIndeterminateProgressIndicatorCell *cell = [[[AMIndeterminateProgressIndicatorCell alloc] init] autorelease];
	[cell setSpinning:YES];
	[cell setDisplayedWhenStopped:NO];
	[cell setColor:[NSColor whiteColor]];
	NSTimer *theTimer = [[NSTimer scheduledTimerWithTimeInterval:[cell animationDelay] target:self selector:@selector(animateSpinner:) userInfo:NULL repeats:YES] retain];
	// keep running while menu is open
	[[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSEventTrackingRunLoopMode];
	[oProgressIndicator setCell:cell];
	[oProgressIndicator setHidden:YES];
}

- (void)animateSpinner:(NSTimer *)aTimer
{	double value = fmod(([[oProgressIndicator cell] doubleValue] + (5.0/60.0)), 1.0);
	[[oProgressIndicator cell] setDoubleValue:value];
	[oProgressIndicator setNeedsDisplay:YES];
}

- (void)show
{
	[oCancelButton setNeedsDisplay:YES];
	[NSAnimationContext beginGrouping];
    [[self animator] setHidden:NO];
	[[oProgressIndicator animator] setHidden:NO];
    [NSAnimationContext endGrouping];
}

- (void)hide
{
	[NSAnimationContext beginGrouping];
    [[self animator] setHidden:YES];
	[[oProgressIndicator animator] setHidden:YES];
    [NSAnimationContext endGrouping];
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


