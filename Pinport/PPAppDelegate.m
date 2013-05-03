//
//  GPAppDelegate.m
//  Pinport
//
//  Created by Michael on 03.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//

#import "PPAppDelegate.h"


@interface PPAppDelegate (Private)
- (void)_connectToPinboardWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;
@end


@implementation PPAppDelegate (Private)

- (void)_connectToPinboardWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
	//
}

@end


#pragma mark -


@implementation PPAppDelegate

#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	DLog(@"called");
	
	[self.progressBar setHidden:YES];
	[self.progressBar setMinValue:0.];
	[self.progressBar setMaxValue:1.];
	
	[self.uploadButton setEnabled:NO];
	
	[self addObserver:self forKeyPath:@"pinboardUsername"	options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"pinboardPassword"	options:NSKeyValueObservingOptionNew context:NULL];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

#pragma mark NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	DLog(@"called w/ keyPath '%@' and change '%@'",keyPath,change);
	
	if (object == self) {
		if (  [keyPath isEqualToString:@"pinboardUsername"]
			||[keyPath isEqualToString:@"pinboardPassword"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.uploadButton setEnabled:(self.pinboardUsername.length > 0 && self.pinboardPassword.length > 0)];
			});
		}
	}
}

#pragma mark IBAction methods

- (IBAction)pushImport:(NSButton *)sender {
	DLog(@"called");
}

- (IBAction)pushUpload:(NSButton *)sender {
	DLog(@"called");
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = @"Connecting...";
			
			[self.progressBar setIndeterminate:YES];
			[self.progressBar startAnimation:self];
			[self.progressBar setHidden:NO];
		});
		
		[NSThread sleepForTimeInterval:2.];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.progressBar setIndeterminate:NO];
			[self.progressBar startAnimation:self];
		});
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = @"Uploading...";
			[self.progressBar setDoubleValue:.5];
		});
		
		[NSThread sleepForTimeInterval:5.];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = @"Done.";
			
			[self.progressBar setHidden:YES];
			[self.progressBar stopAnimation:self];
		});
	});
}

@end
