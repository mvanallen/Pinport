//
//  GPAppDelegate.h
//  Pinport
//
//  Created by Michael on 03.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSProgressIndicator	*progressBar;
@property (weak) IBOutlet NSTextField			*statusLabel;

@property (weak) IBOutlet NSButton *importButton;
@property (weak) IBOutlet NSButton *uploadButton;

@property (strong)	NSString	*pinboardUsername;
@property (strong)	NSString	*pinboardPassword;

- (IBAction)pushImport:(NSButton *)sender;
- (IBAction)pushUpload:(NSButton *)sender;
@end
