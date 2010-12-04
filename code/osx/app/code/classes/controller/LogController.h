/* See bottom of file for license and copyright information */

#import <Cocoa/Cocoa.h>

@interface LogController : NSObject {
	IBOutlet NSTextView* oLogView;
}
- (void)processLogResults:(NSString*)processResult;
- (NSAttributedString*)createLink:(NSString*)label path:(NSString*)path;
- (void)processErrorResults:(NSString*)logString;
- (NSAttributedString*)formatErrorText:(NSString*)inText;
- (NSAttributedString*)formatGrayText:(NSString*)inText;
- (NSAttributedString*)formatNewline;
- (NSAttributedString*)formatString:(NSString*)logString;
- (void)clearLog;
- (void)writeString:(NSString*)logString;
- (void)writeDate;
- (void)logAttString:(NSAttributedString*)inText;
- (void)scrollViewToBottom;

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

