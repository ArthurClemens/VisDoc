/* See bottom of file for license and copyright information */

#import "MyDocument.h"
#import "SimplePerlBridge.h"
#import "StringAdditions.h"
#import "ProgressView.h"
#import "interfacestrings.h"
#import "SelectableTableView.h"
#import "PathInfo.h"
#import "LogController.h"
#import "LayoutSettingsController.h"

static NSString* sValidExtensions = @"as,java";
static NSMutableDictionary* sDefaultSettings;

@implementation MyDocument

@synthesize settings;
@synthesize listedPaths;

- (id)init
{	
    self = [super init];
    if (self) {
		settings = [[NSMutableDictionary alloc] init];
		[self initializeListedPaths];
		[self initializeProjectData];
    }
    return self;
}

- (void)awakeFromNib
{
	[oWindow center];
	[[oWindow contentView] addSubview:oProgressView];
	
	[oInputFilesTable setDelegate:self];
    [oInputFilesTable setDataSource:self];
	
	[self updateInterface];
}

- (void)dealloc
{
	[self unRegisterForChangedKeys];
	[listedPaths release];
	[settings release];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

/*
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
}
*/

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSData* documentData = nil;
	if ([typeName isEqualToString:@"DocumentType"]) {
		NSMutableDictionary* allData = [[[NSMutableDictionary alloc] init] autorelease];
		[allData setObject:[self settings] forKey:@"settings"];
		[allData setObject:[self listedPaths] forKey:@"listedPaths"];
		documentData = [NSKeyedArchiver archivedDataWithRootObject:allData];
	}
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return documentData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	@try {
		NSMutableDictionary* allData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		if (allData) {
			[self unRegisterForChangedKeys];
			NSMutableDictionary* projectSettings = [allData objectForKey:@"settings"];
			// new default settings may not be in the project file, so merge
			[self cleanupSettings:projectSettings];
			[self setSettings:projectSettings];
			[self setListedPaths:[allData objectForKey:@"listedPaths"]];
			[oLayoutSettingsController updateUsesDefaults];
			[self updateCount];
			[self registerForChangedKeys];
		}
	}
	@catch (NSException *e) {
		if (outError) { 
			NSDictionary *d = [NSDictionary dictionaryWithObject:@"Could not read project file." 
														  forKey:NSLocalizedFailureReasonErrorKey];
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain 
											code:unimpErr 
										userInfo:d];
		} 
		return NO;
	}
	
	return YES;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL success = [super writeToURL:absoluteURL ofType:typeName error:outError];
	return success;
}

- (void)handleAppChanged
{
	[self updateChangeCount:NSChangeDone];
	[self updateInterface];
}

#pragma mark Processing

- (IBAction)startProcessing:(id)sender
{
	[self prepareProcessing];
	[self processFiles];
}

- (void)prepareProcessing
{
	[oProcessButton setEnabled:NO];
	[oInputFilesTable deselectAll:self];
	[oLogController clearLog];
}

- (void)processFiles
{
	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"VisDoc" ofType:@"pl" inDirectory:@"perl"];
	NSAssert1 (scriptPath, @"runProjectInPerl -- script file '%@' not found", @"perl/VisDoc");
	
	NSArray * paths = [self validAndSelectedPaths];
	NSString* pathsString = [paths componentsJoinedByString:@","];
	
	NSMutableArray* argumentList = [[[NSMutableArray alloc] init] autorelease];
	[argumentList addObject:@"-doc-sources"];
	[argumentList addObject:pathsString];
	
	NSEnumerator* e = [[self settings] keyEnumerator];
	NSString* key = nil;
	while (key = [e nextObject]) {
		id value = [[self settings] objectForKey:key];
		NSString* stringValue = [NSString stringWithFormat:@"%@", value];
		/*
		if ( ![key isEqualToString:@"output"] ) {
			if ([stringValue rangeOfString:@" "].location != NSNotFound) {
				// has spaces, use quotes
				unichar uchar = 0x005C;
				NSString* escapedChar = [NSString stringWithFormat:@"%u ", uchar];
				stringValue = [stringValue stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
			}
		}
		*/
		
		if (![stringValue isEqualToString:@""]) {
			[argumentList addObject:[NSString stringWithFormat:@"-%@", key]];
			[argumentList addObject:stringValue];
		}
	}
	
	[self showProgress];
	
	// log this command
	NSString* commandString = [NSString stringWithFormat:@"perl %@ %@", scriptPath, [self argumentListToString:argumentList]];
	[oLogController writeString:[NSString stringWithFormat:@"Executing command:\n%@", commandString]];
	
	SimplePerlBridge* perl = [[[SimplePerlBridge alloc] init] autorelease];
	NSString* stringFromPerl = [perl runScript:scriptPath argumentList:argumentList readFromFile:YES];
	NSDictionary* processResult = [SimplePerlBridge propertyListFromString:stringFromPerl];
	
	[self handleProcessResult:processResult];	
	
	[self hideProgress];
}

- (NSString*)argumentListToString:(NSArray*)argumentList
{
	NSMutableString* out = [[[NSMutableString alloc] init] autorelease];
	NSEnumerator* e = [argumentList objectEnumerator];
	NSString* argument = nil;
	while (argument = [e nextObject]) {
		unichar first = [argument characterAtIndex:0];
		
		if (first == '-') {
			[out appendString:argument];
		} else {
			[out appendFormat:@"\"%@\"", argument];
			//[out appendString:argument];
		}
		[out appendString:@" "];
	}
	return out;
}

- (void)handleProcessResult:(NSDictionary*)processResult
{	
	if (!processResult) {
		[oLogController writeString:@"No results, but no errors passed either."];
		return;
	}
	[oLogController processErrorResults:[processResult objectForKey:@"error"]];
	if (![processResult objectForKey:@"error"]) {
		[oLogController processLogResults:[processResult objectForKey:@"log"]];
	}
}

- (void)_openURL:(NSString*)path
	  withParam:(NSString*)param
{
	NSURL* url = [NSURL fileURLWithPath:path];
	if (param != nil) {
		NSURL* paramURL = [NSURL fileURLWithPath:param];
		NSString* absoluteString = [url absoluteString];
		NSString* paramURLAbsoluteString = [paramURL absoluteString];
		absoluteString = [NSString stringWithFormat:@"%@?%@", absoluteString, paramURLAbsoluteString];
		url = [NSURL URLWithString:absoluteString];
	}
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)stopProcessing:(id)sender 
{
	[self hideProgress];
}

- (void)showProgress
{	
	[oProgressView show];
}

- (void)hideProgress
{
	[oProgressView hide];
	[self showMainApplicationWindow];
	
	//[oDockIndicator setHidden:YES];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"onProcessingFinished" object:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo
{
	//
}

- (void)showMainApplicationWindow
{	
	// return focus to content view, so that the Process button can be invoke by pressing Enter again
	[oWindow makeFirstResponder:[oWindow contentView]];
	[oProcessButton setState:NSOnState];
	[self updateInterface];
}

#pragma mark Interface

- (void)updateInterface
{	
	[self _updateCountInternally];
	[oInputFilesTable reloadData];
	[oProcessButton setEnabled:[self isProcessButtonEnabled]];
	[self _updateFeedback];
}

- (BOOL)isProcessButtonEnabled
{
	if ( ![self _validAndSelectedPathCount] > 0 ) return NO;
	if ( ![[settings objectForKey:@"output"] isValidString] ) return NO;
	return YES;
}

- (NSMutableAttributedString*)status
{
	NSString* selectedFilesString; 
	int mainTextLength = 0;
	
	if (![self listedPaths] || [[self listedPaths] count] == 0) {
		selectedFilesString = IFACE_NOINPUTFILES;
	} else if (selectedPathCount == 0) {
		selectedFilesString = IFACE_NOTHINGSELECTED;
    } else {
		NSString* filesString = validAndListedFileCount == 1 ? IFACE_FILE : IFACE_FILES;
		NSString* directoriesString = validAndListedDirCount == 1 ? IFACE_DIRECTORY : IFACE_DIRECTORIES;
		NSString* selectedFiles = validAndListedFileCount != 0 ? [NSString stringWithFormat:@"%d %@", validAndListedFileCount, filesString] : @"";
		NSString* selectedDirs = validAndListedDirCount != 0 ? [NSString stringWithFormat:@"%d %@", validAndListedDirCount, directoriesString] : @"";
		NSString* separator = (validAndListedFileCount != 0 && validAndListedDirCount != 0) ? [NSString stringWithFormat:@" %@ ", IFACE_AND] : @"";
		selectedFilesString = [NSString stringWithFormat:@"%@%@%@ %@", selectedDirs, separator, selectedFiles, IFACE_SELECTED];
		mainTextLength = [selectedFilesString length];

		int validFileCount = [self _validAndSelectedPathCount];
		NSString* validFilesString = validFileCount == 1 ? IFACE_VALIDFILE : IFACE_VALIDFILES;
		selectedFilesString = [selectedFilesString stringByAppendingFormat:[NSString stringWithFormat:@"\n%@ %d %@", IFACE_CONTAINING, validFileCount, validFilesString]];
	}
	NSMutableAttributedString* selectedFilesAttrStr = [[[NSMutableAttributedString alloc] initWithString:selectedFilesString] autorelease];

	// color selected files string
	
	
	if (selectedPathCount > 0) {
		// black
		NSDictionary* colorAttr = [NSDictionary dictionaryWithObject:[NSColor blackColor]
															  forKey:NSForegroundColorAttributeName];
		[selectedFilesAttrStr addAttributes:colorAttr range:NSMakeRange(0, mainTextLength)];
	}
	
	NSMutableAttributedString* totalText = [[[NSMutableAttributedString alloc] init] autorelease];
	[totalText appendAttributedString:selectedFilesAttrStr];
   
	return totalText;
}

- (void)_updateFeedback
{	
	NSString* selectedFilesString; 
	int mainTextLength = 0;
	
	if (![self listedPaths] || [[self listedPaths] count] == 0) {
		selectedFilesString = IFACE_NOINPUTFILES;
	} else if (selectedPathCount == 0) {
		selectedFilesString = IFACE_NOTHINGSELECTED;
    } else {
		NSString* filesString = validAndListedFileCount == 1 ? IFACE_FILE : IFACE_FILES;
		NSString* directoriesString = validAndListedDirCount == 1 ? IFACE_DIRECTORY : IFACE_DIRECTORIES;
		NSString* selectedFiles = validAndListedFileCount != 0 ? [NSString stringWithFormat:@"%d %@", validAndListedFileCount, filesString] : @"";
		NSString* selectedDirs = validAndListedDirCount != 0 ? [NSString stringWithFormat:@"%d %@", validAndListedDirCount, directoriesString] : @"";
		NSString* separator = (validAndListedFileCount != 0 && validAndListedDirCount != 0) ? [NSString stringWithFormat:@" %@ ", IFACE_AND] : @"";
		selectedFilesString = [NSString stringWithFormat:@"%@%@%@ %@", selectedDirs, separator, selectedFiles, IFACE_SELECTED];
		mainTextLength = [selectedFilesString length];

		int validFileCount = [self _validAndSelectedPathCount];
		NSString* validFilesString = validFileCount == 1 ? IFACE_VALIDFILE : IFACE_VALIDFILES;
		selectedFilesString = [selectedFilesString stringByAppendingFormat:[NSString stringWithFormat:@"\n%@ %d %@", IFACE_CONTAINING, validFileCount, validFilesString]];
	}
	NSMutableAttributedString* selectedFilesAttrStr = [[[NSMutableAttributedString alloc] initWithString:selectedFilesString] autorelease];

	// color selected files string
		
	if (selectedPathCount > 0) {
		// black
		NSDictionary* colorAttr = [NSDictionary dictionaryWithObject:[NSColor blackColor]
															  forKey:NSForegroundColorAttributeName];
		[selectedFilesAttrStr addAttributes:colorAttr range:NSMakeRange(0, mainTextLength)];
	}
	
	NSMutableAttributedString* totalText = [[[NSMutableAttributedString alloc] init] autorelease];
	[totalText appendAttributedString:selectedFilesAttrStr];
    
	[oFeedbackTextField setAttributedStringValue:totalText];
}

#pragma mark Settings

- (void)initializeListedPaths
{
	if ([self listedPaths] != nil) {
		return;
	}
	listedPaths = [[NSMutableArray alloc] init];
}

- (void)initializeProjectData
{
	if ([[[self settings] allKeys] count] != 0) {
		return;	
	}

	if (!sDefaultSettings) {
		sDefaultSettings = [[NSMutableDictionary alloc] init];
	}
	NSDictionary* defaultSettings;

	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"pl" inDirectory:@"perl"];	
	if (!scriptPath) return;
	
	// check for new default settings
	// these may not be stored in the project file yet
	NSArray* argumentList = nil;
	SimplePerlBridge* p = [[[SimplePerlBridge alloc] init] autorelease];
	NSString* stringFromPerl = [p runScript:scriptPath argumentList:argumentList readFromFile:NO];
	defaultSettings = [[SimplePerlBridge propertyListFromString:stringFromPerl] retain];
	
	NSEnumerator* e = [defaultSettings keyEnumerator];
	NSString* key = nil;
	while (key = [e nextObject]) {
		if ([sDefaultSettings objectForKey:key] == nil) {
			[sDefaultSettings setObject:[defaultSettings objectForKey:key] forKey:key];
		}
	}

	[settings addEntriesFromDictionary:sDefaultSettings];
	[self registerForChangedKeys];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
	[oLayoutSettingsController updateUsesDefaults];
	[self handleAppChanged];
}

- (void)registerForChangedKeys
{
	NSEnumerator* e = [settings keyEnumerator];
	NSString* key;
	while (key = [e nextObject]) {
		[self addObserver:self
			   forKeyPath:[NSString stringWithFormat:@"settings.%@", key]
				  options:NSKeyValueChangeSetting
				  context:nil];
	}
}

- (void)unRegisterForChangedKeys
{
	NSEnumerator* e = [settings keyEnumerator];
	NSString* key;
	while (key = [e nextObject]) {
		[self removeObserver:self
				  forKeyPath:[NSString stringWithFormat:@"settings.%@", key]];
	}
}

- (IBAction)restoreToDefaultValues:(id)sender
{
	// keep out directory
	NSString* out = [settings objectForKey:@"output"];
	
	[settings removeAllObjects];
	[settings addEntriesFromDictionary:sDefaultSettings];
	[settings setObject:out forKey:@"output"];
}

- (NSDictionary*)defaultSettings
{
	return sDefaultSettings;
}

/**
New default settings may not be in the project file, so merge
*/

- (void)cleanupSettings:(NSMutableDictionary*)rawSettings
{
	NSEnumerator* e = [sDefaultSettings keyEnumerator];
	NSString* key = nil;
	while (key = [e nextObject]) {
		if ([rawSettings objectForKey:key] == nil) {
			[rawSettings setObject:[sDefaultSettings objectForKey:key] forKey:key];
		}
	}

	// remove settings that are not in the defaults
	e = [rawSettings keyEnumerator];
	NSMutableArray* removeKeys = [[[NSMutableArray alloc] init] autorelease];
	key = nil;
	while (key = [e nextObject]) {
		if ([sDefaultSettings objectForKey:key] == nil) {
			[removeKeys addObject:key];
		}
	}
	if ([removeKeys count] > 0) { 
		[rawSettings removeObjectsForKeys:removeKeys];	
	}
}

#pragma mark Paths

- (void)_addPaths:(NSArray*)paths
{
	NSEnumerator* e = [paths objectEnumerator];
	NSString* path = nil;
	while (path = [e nextObject]) {
		[self _addPath:path];
	}
}

- (void)_addPath:(NSString*)path
{
	// check if path is not listed already
	PathInfo* pathInfo = [self _pathInfoForPath:path];
	if (!pathInfo) {
		pathInfo = [[[PathInfo alloc] initWithPath:path] autorelease];
		[pathInfo setIsSelected:YES];
		[self insertObject:pathInfo inListedPathsAtIndex:[self countOfListedPaths]];
	}
}

- (void)updateCount
{
	validAndListedFileCount = 0;
	validAndListedDirCount = 0;
	selectedPathCount = 0;
	
	if ([[self listedPaths] count] > 0) {
		[oCountProgress startAnimation:self];
		[self _threadedUpdateCount];
		[self _threadedUpdateCountDone];
	}
}

/**
 Calls _getStatusOfFilesAndFolders to let Perl return file info on the list of paths in listedPaths.
 */
- (void)_threadedUpdateCount
{
	NSDictionary* fileInfo = [self _getStatusOfFilesAndFolders:[self paths]];
	
	// interpret data and write to pathInfo
	[self _parsePathInfoFromDictionary:[fileInfo objectForKey:@"validListedDirs"] isDir:YES];
	[self _parsePathInfoFromDictionary:[fileInfo objectForKey:@"invalidListedDirs"] isDir:YES];
	[self _parsePathInfoFromDictionary:[fileInfo objectForKey:@"validListedFiles"] isDir:NO];
	[self _parsePathInfoFromDictionary:[fileInfo objectForKey:@"invalidListedFiles"] isDir:NO];
}

- (void)_parsePathInfoFromDictionary:(NSDictionary*)fileInfo isDir:(BOOL)isDir
{
	if (fileInfo) {
		NSEnumerator* e = [fileInfo keyEnumerator];
		NSString* path = nil;
		while (path = [e nextObject]) {
			PathInfo* pathInfo = [self _pathInfoForPath:path];
			if (pathInfo) {
				int validFileCount = [[fileInfo objectForKey:path] intValue];
				[pathInfo setValidFileCount:validFileCount];
				if (validFileCount == 0) {
					[pathInfo setIsSelected:NO];	
				}
				[pathInfo setIsDir:isDir];
			}
		}
	}
}

- (void)_threadedUpdateCountDone
{
	[oCountProgress stopAnimation:self];
	//[self performSelectorOnMainThread:@selector(updateInterface) withObject:nil waitUntilDone:NO];
	[self updateInterface];
}

- (PathInfo*)_pathInfoForPath:(NSString*)path
{
	for (PathInfo *pathInfo in [self listedPaths]) {
		if ([[pathInfo path] isEqualToString:path] ) {
			return pathInfo;
		}
	}
	// else
	return nil;
}

- (void)_updateCountInternally
{	
	if (![self listedPaths]) return;
	
	NSPredicate *testIsValidAndSelected = [NSPredicate predicateWithFormat:@"isValidAndSelected == YES"];
	NSArray* validAndSelectedPaths = [[self listedPaths] filteredArrayUsingPredicate:testIsValidAndSelected];
	
	NSPredicate *testIsDir = [NSPredicate predicateWithFormat:@"isDir == YES"];
	NSArray* selectedDirs = [validAndSelectedPaths filteredArrayUsingPredicate:testIsDir];
	
	selectedPathCount = [validAndSelectedPaths count];
	int selectedDirCount = [selectedDirs count];
	
	validAndListedFileCount = selectedPathCount - selectedDirCount;
	validAndListedDirCount = selectedDirCount;
}

/**
 Reads listedPaths and returns an array of path strings.
 */
- (NSArray*)paths
{
	NSMutableArray* paths = [[[NSMutableArray alloc] initWithCapacity:[[self listedPaths] count]] autorelease];
	NSEnumerator* e = [[self listedPaths] objectEnumerator];
	NSString* path = nil;
	while ( path = [[e nextObject] path] ) {
		[paths addObject:path];
	}
	return paths;
}

/**
 Lets Perl return file info on the list of path strings.
 Returns data as dictionary.
 */
- (NSDictionary*)_getStatusOfFilesAndFolders:(NSArray*)inPaths
{	
	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"cocoaBridge" ofType:@"pl" inDirectory:@"perl"];
	NSAssert1 (scriptPath, @"_getStatusOfFilesAndFolders -- script file '%@' not found", @"perl/getFilesAndDirs");
	
	NSString* paths = [inPaths componentsJoinedByString:@","];
	NSArray* argumentList = [NSArray arrayWithObjects:
							 @"-files", paths,
							 @"-extensions", sValidExtensions,
							 nil];
	
	SimplePerlBridge* p = [[[SimplePerlBridge alloc] init] autorelease];
	NSString* stringFromPerl = [p runScript:scriptPath argumentList:argumentList readFromFile:YES];
	NSDictionary* fileInfo = [SimplePerlBridge propertyListFromString:stringFromPerl];
	return fileInfo;
}

- (int)_validAndSelectedPathCount
{
	int count = 0;
	NSEnumerator* e = [[self listedPaths] objectEnumerator];
	PathInfo* p;
	while (p = [e nextObject]) {
		if ([p isSelected]) {
			count += [p validFileCount];
		}
	}
	return count;
}

- (NSArray*)validAndSelectedPaths
{
	NSMutableArray* paths = [[[NSMutableArray alloc] initWithCapacity:[[self listedPaths] count]] autorelease];
	NSEnumerator* e = [[self listedPaths] objectEnumerator];
	PathInfo* p;
	while (p = [e nextObject]) {
		if ([p isSelected] && [p validFileCount] > 0) {
			[paths addObject:[p path]];
		}
	}
	return paths;
}

- (IBAction)addInputPath:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setResolvesAliases:YES];
	[openPanel setPrompt:IFACE_SELECT];
	/*
	 NSData* lastInputDirectoryAliasData = [(NSUserDefaults*)[[ProjectController sharedProjectController] projectData] objectForKey:@"lastInputDirectory"];
	 NDAlias* lastInputDirectoryAlias = [NDAlias aliasWithData:lastInputDirectoryAliasData];
	 */
	NSArray* validFileExtensions = [NSArray arrayWithObjects:@"as", @"java", nil];
	
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                                types:validFileExtensions
                       modalForWindow:[sender window]
                        modalDelegate:self
                       didEndSelector:@selector(addInputPathPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)addInputPathPanelDidEnd:(NSOpenPanel*)sheet
					 returnCode:(int)returnCode
					contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton) {
		NSArray* newPaths = [sheet filenames];
		if (newPaths != nil) {
			[self _addPaths:newPaths];
			[self updateCount];
			[oInputFilesTable reloadData];
		}
	}
}

- (IBAction)addOutputPath:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setResolvesAliases:YES];
	[openPanel setPrompt:IFACE_SELECT];
	
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                                types:nil
                       modalForWindow:[sender window]
                        modalDelegate:self
                       didEndSelector:@selector(addOutputPathPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)addOutputPathPanelDidEnd:(NSOpenPanel*)sheet
					  returnCode:(int)returnCode
					 contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton) {
		NSArray* newPaths = [sheet filenames];
		if (newPaths != nil) {
			[self setOutDirectory:[newPaths objectAtIndex:0]];
		}
	}
}

#pragma mark PathInfo array

- (NSUInteger)countOfListedPaths
{
    return [[self listedPaths] count];	
}

- (id)objectInListedPathsAtIndex:(NSUInteger)idx
{
    return [[self listedPaths] objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inListedPathsAtIndex:(NSUInteger)idx
{
    [[self listedPaths] insertObject:anObject atIndex:idx];
	[self handleAppChanged];
}

- (void)removeObjectFromListedPathsAtIndex:(NSUInteger)idx
{
    [[self listedPaths] removeObjectAtIndex:idx];
	[self handleAppChanged];
}

- (void)replaceObjectInListedPathsAtIndex:(NSUInteger)idx withObject:(id)anObject
{
    [[self listedPaths] replaceObjectAtIndex:idx withObject:anObject];
	[self handleAppChanged];
}

#pragma mark Out directory

- (void)setOutDirectory:(NSString*)path
{
	[settings setObject:path forKey:@"output"];
	[self updateInterface];
}


#pragma mark Table 

- (void)selectButtonClicked:(id)sender
{
	[self handleAppChanged];
}

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	NSArray* types = [[info draggingPasteboard] types];
	if (row != -1) {
		if ( [types containsObject:NSFilenamesPboardType] && op==NSTableViewDropAbove) {
			int tOriginalRow;
			tOriginalRow= *((int *) [[[info draggingPasteboard] dataForType:NSFilenamesPboardType] bytes]);
			if ( row != tOriginalRow && row != (tOriginalRow+1) ) {
				return NSDragOperationMove;
			}
		}
	}
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
	int tOriginalRow;
	int tDestinationRow;
	NSPasteboard *pboard = [info draggingPasteboard];
	tOriginalRow= *((int *) [[pboard dataForType:NSFilenamesPboardType] bytes]);
	tDestinationRow=row;
	if (tDestinationRow>tOriginalRow) {
		tDestinationRow--;
	}
	NSArray* paths = [pboard propertyListForType:NSFilenamesPboardType];
	NSEnumerator* e = [paths objectEnumerator];
	NSString* path = nil;
	while (path = [e nextObject]) {
		path = [path resolveAlias];
		[self _addPath:path];
	}
	[self updateCount];
	
	[tv deselectAll:self];
	[tv reloadData];
	return YES;
}

- (void)onTableRowDelete:(NSTableView*)tv
{
	NSMutableArray* indicesToDelete = [[[NSMutableArray alloc] init] autorelease];
	NSIndexSet* selectedRowIndexes = [tv selectedRowIndexes];
	
	unsigned indexBuffer[[selectedRowIndexes count]];
	unsigned limit = [selectedRowIndexes getIndexes:indexBuffer
										   maxCount:[selectedRowIndexes count]
									   inIndexRange:NULL];
	unsigned idx;
	for (idx = 0; idx < limit; idx++) {
		[indicesToDelete addObject:[NSNumber numberWithUnsignedInt:indexBuffer[idx]]];
	}
	
	NSEnumerator* e = [indicesToDelete reverseObjectEnumerator];
	NSNumber* n;
	while (n = [e nextObject]) {
		[self removeObjectFromListedPathsAtIndex:[n unsignedIntValue]];
	}
	
	[self updateInterface];
	[self handleAppChanged];
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

