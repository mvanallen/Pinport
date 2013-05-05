//
//  GPAppDelegate.h
//  Pinport
//
//  Created by Michael on 03.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PPGoogleReaderImport.h"
#import "PPPinboardConnector.h"


@interface PPAppDelegate : NSObject <NSApplicationDelegate>

@property (strong)	PPGoogleReaderImport	*readerImporter;
@property (strong)	PPPinboardConnector		*pinboardApi;

@property (strong)	NSString				*pinboardUsername;
@property (strong)	NSString				*pinboardPassword;
@property (strong)	NSString				*pinboardToken;

@property (strong)	NSArray					*importedItems;
@property (strong)	NSArray					*uploadedItems;

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField	*importFileField;
@property (weak) IBOutlet NSButton		*redirectionsChkbox;
@property (weak) IBOutlet NSTextField	*tagField;
@property (weak) IBOutlet NSButton		*googleTagsChkbox;
@property (weak) IBOutlet NSButton		*itemTagsChkbox;

@property (weak) IBOutlet NSProgressIndicator	*progressBar;
@property (weak) IBOutlet NSTextField			*statusLabel;

@property (weak) IBOutlet NSButton *importButton;
@property (weak) IBOutlet NSButton *uploadButton;

- (IBAction)pushImport:(NSButton *)sender;
- (IBAction)pushUpload:(NSButton *)sender;
@end
