/* See bottom of file for license and copyright information */

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@class SimplePerlBridge;
@class ProgressView;
@class SelectableTableView;
@class PathInfo;
@class LogController;
@class LayoutSettingsController;

@interface MyDocument : NSDocument
{
	NSMutableDictionary* settings;
	NSMutableArray* listedPaths; /** contains objects of type PathInfo */

	IBOutlet NSWindow* oWindow;
	IBOutlet NSWindow* oProgressSheet;
	IBOutlet ProgressView* oProgressView;
	
	int selectedPathCount;
	int validAndListedFileCount;
	int validAndListedDirCount;
	int addedFileCount;
	int modifiedFileCount;
		
	IBOutlet SelectableTableView* oInputFilesTable;
    IBOutlet NSTextField* oFeedbackTextField;
	IBOutlet NSButton* oProcessButton;
	IBOutlet NSProgressIndicator* oCountProgress;
	IBOutlet LogController* oLogController;
	IBOutlet LayoutSettingsController* oLayoutSettingsController;
}
@property (readwrite, retain) NSMutableDictionary* settings;
@property (readwrite, retain) NSMutableArray* listedPaths;

#pragma mark Processing
- (IBAction)startProcessing:(id)sender;
- (void)prepareProcessing;
- (void)processFiles;
- (NSString*)argumentListToString:(NSArray*)argumentList;
- (void)handleProcessResult:(NSDictionary*)processResult;
- (IBAction)stopProcessing:(id)sender ;
- (void)handleAppChanged;
- (void)showProgress;
- (void)hideProgress;
- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo;
- (void)_openURL:(NSString*)path
	   withParam:(NSString*)param;
- (void)showMainApplicationWindow;

- (void)initializeListedPaths;
- (void)initializeProjectData;
- (void)_addPath:(NSString*)path;
- (void)updateCount;
- (void)_updateCountInternally;
- (void)_threadedUpdateCount;
- (void)_threadedUpdateCountDone;
- (void)_parsePathInfoFromDictionary:(NSDictionary*)fileInfo isDir:(BOOL)isDir;
- (PathInfo*)_pathInfoForPath:(NSString*)path;
- (NSDictionary*)_getStatusOfFilesAndFolders:(NSArray*)paths;
- (NSArray*)paths;
- (void)_updateFeedback;
- (void)updateInterface;
- (BOOL)isProcessButtonEnabled;
- (IBAction)addInputPath:(id)sender;
- (void)addInputPathPanelDidEnd:(NSOpenPanel*)sheet
					 returnCode:(int)returnCode
					contextInfo:(void*)contextInfo;
- (int)_validAndSelectedPathCount;
- (IBAction)addOutputPath:(id)sender;
- (void)addOutputPathPanelDidEnd:(NSOpenPanel*)sheet
					  returnCode:(int)returnCode
					 contextInfo:(void*)contextInfo;
- (NSMutableAttributedString*)status;

- (IBAction)restoreToDefaultValues:(id)sender;

#pragma mark Paths

- (NSArray*)validAndSelectedPaths;

#pragma mark Out directory
- (void)setOutDirectory:(NSString*)path;

#pragma mark Settings
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (void)registerForChangedKeys;
- (void)unRegisterForChangedKeys;
- (NSDictionary*)defaultSettings;
- (void)cleanupSettings:(NSMutableDictionary*)rawSettings;

#pragma mark Table
- (void)selectButtonClicked:(id)sender;
- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op;
- (void)onTableRowDelete:(NSTableView*)tv;

#pragma mark PathInfo array
- (NSUInteger)countOfListedPaths;
- (id)objectInListedPathsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inListedPathsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromListedPathsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInListedPathsAtIndex:(NSUInteger)idx withObject:(id)anObject;

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
