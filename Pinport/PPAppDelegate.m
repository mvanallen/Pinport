//
//  GPAppDelegate.m
//  Pinport
//
//  Created by Michael on 03.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//
//	Licenced under the MIT licence: http://www.opensource.org/licenses/MIT
//

#import "PPAppDelegate.h"


@implementation PPAppDelegate

#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	DLog(@"called");
	
	self.readerImporter	= [[PPGoogleReaderImport alloc] init];
	self.pinboardApi	= [[PPPinboardConnector alloc] init];
	
	[self.uploadButton setEnabled:NO];
	
	[self.progressBar setHidden:YES];
	[self.progressBar setMinValue:0.];
	[self.progressBar setMaxValue:1.];
	
	[self addObserver:self forKeyPath:@"importedItems"		options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"pinboardUsername"	options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"pinboardPassword"	options:NSKeyValueObservingOptionNew context:NULL];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

#pragma mark NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	//DLog(@"called w/ keyPath '%@' and change '%@'",keyPath,change);
	
	if (object == self) {
		if (  [keyPath isEqualToString:@"importedItems"]
			||[keyPath isEqualToString:@"pinboardUsername"]
			||[keyPath isEqualToString:@"pinboardPassword"]	) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.uploadButton setEnabled:(self.importedItems.count > 0 && self.pinboardUsername.length > 0 && self.pinboardPassword.length > 0)];
			});
		}
	}
}

#pragma mark IBAction methods

- (IBAction)pushImport:(NSButton *)sender {
	DLog(@"called");
	
	self.importedItems = nil;
	self.uploadedItems = @[];
	
	NSMutableArray	*itemsSuccessfullyImported	= [NSMutableArray array];
	
	NSString *filePath = [self.importFileField.stringValue stringByStandardizingPath];
	NSURL *importFileUrl = filePath.length > 0 ? [NSURL fileURLWithPath:filePath] : nil;
	
	if (!(importFileUrl && [[NSFileManager defaultManager] fileExistsAtPath:importFileUrl.path])) {
		return;
	}
	
	PPGoogleReaderImportOptions	options				= 0;
	NSArray						*additionalTags		= nil;
	BOOL						shouldResolveUrls	= (self.redirectionsChkbox.state == NSOnState);
	
	if (self.googleTagsChkbox.state	== NSOnState) options |= PPGoogleReaderImportOmitGoogleTags;
	if (self.itemTagsChkbox.state	== NSOnState) options |= PPGoogleReaderImportOmitItemTags;
	
	NSString *tags = [self.tagField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (tags.length > 0)
		additionalTags = [tags componentsSeparatedByString:@" "];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = @"Loading...";
			
			[self.progressBar setHidden:NO];
			[self.progressBar setIndeterminate:YES];
			[self.progressBar startAnimation:self];
		});
		
		if ([self.readerImporter loadItemsAtUrl:importFileUrl]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.statusLabel.stringValue = @"Processing entries...";
				
				[self.progressBar setIndeterminate:NO];
				[self.progressBar startAnimation:self];
			});
			
			NSUInteger importCount = 0;
			for (NSDictionary *item in self.readerImporter.items) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.progressBar setDoubleValue:importCount/(double)self.readerImporter.items.count];
				});
				
				PPPinboardItem *pinboardItem = [PPGoogleReaderImport pinboardItemFromGoogleReaderItem:item options:options];
				if (pinboardItem) {
					if (	shouldResolveUrls
						&& (  [pinboardItem.url.host isEqualToString:@"feedproxy.google.com"]
							||[pinboardItem.url.host isEqualToString:@"rss.feedsportal.com"]	)) {
						
						[pinboardItem resolveURLRedirections];
					}
					
					pinboardItem.descriptions = nil;
					
					if (additionalTags.count > 0)
						pinboardItem.tags = [pinboardItem.tags arrayByAddingObjectsFromArray:additionalTags];
					
					[itemsSuccessfullyImported addObject:pinboardItem];
					DLog(@"Imported item: %@",pinboardItem);
				}
				
				importCount++;
			}
			
			self.importedItems = [NSArray arrayWithArray:itemsSuccessfullyImported];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = [NSString stringWithFormat:@"Done. (imported: %lu, failed: %lu)"
											,(unsigned long)itemsSuccessfullyImported.count
											,(unsigned long)(self.readerImporter.items.count - itemsSuccessfullyImported.count)	];
			
			[self.progressBar stopAnimation:self];
			[self.progressBar setHidden:YES];
		});
	});
}

- (IBAction)pushUpload:(NSButton *)sender {
	DLog(@"called");
	
	NSMutableArray	*itemsToBeUploaded			= [self.importedItems mutableCopy];
	[itemsToBeUploaded removeObjectsInArray:self.uploadedItems];
	
	NSMutableArray	*itemsSuccessfullyUploaded	= [NSMutableArray arrayWithCapacity:itemsToBeUploaded.count];
	
	if (itemsToBeUploaded.count <= 0) {
		return;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = @"Connecting...";
			
			[self.progressBar setHidden:NO];
			[self.progressBar setIndeterminate:YES];
			[self.progressBar startAnimation:self];
		});
		
		if (self.pinboardToken <= 0) {
			self.pinboardToken = [self.pinboardApi authTokenForAccountWithUsername:self.pinboardUsername andPassword:self.pinboardPassword];
		}
		
		if (self.pinboardToken.length > 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.statusLabel.stringValue = @"Uploading...";
				
				[self.progressBar setIndeterminate:NO];
				[self.progressBar startAnimation:self];
			});
			
			NSUInteger uploadCount = 0;
			for (PPPinboardItem *item in itemsToBeUploaded) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.progressBar setDoubleValue:uploadCount/(double)itemsToBeUploaded.count];
				});
				
				NSString *result = [self.pinboardApi usingToken:self.pinboardToken uploadItem:item overwriteExisting:NO];
				DLog(@"Upload got result '%@' for item: %@",result,item.title);
				
				if ([result isEqualToString:@"done"]) {
					[itemsSuccessfullyUploaded addObject:item];
				}
				
				uploadCount++;
			}
			
			if (itemsSuccessfullyUploaded.count > 0)
				self.uploadedItems = [self.uploadedItems arrayByAddingObjectsFromArray:itemsSuccessfullyUploaded];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.statusLabel.stringValue = [NSString stringWithFormat:@"Done. (uploaded: %lu, failed: %lu)"
											,(unsigned long)itemsSuccessfullyUploaded.count
											,(unsigned long)(itemsToBeUploaded.count - itemsSuccessfullyUploaded.count)	];
			
			[self.progressBar stopAnimation:self];
			[self.progressBar setHidden:YES];
		});
	});
}

@end
