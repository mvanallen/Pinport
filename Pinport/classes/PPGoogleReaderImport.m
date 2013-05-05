//
//  PPGoogleReaderImport.m
//  Pinport
//
//  Created by Michael on 04.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//

#import "PPGoogleReaderImport.h"

#import "PPPinboardConnector.h"


@implementation PPGoogleReaderImport

#pragma mark Class methods

+ (PPPinboardItem *)pinboardItemFromGoogleReaderItem:(NSDictionary *)theItemDict options:(PPGoogleReaderImportOptions)importOptions {
	PPPinboardItem *item = [[PPPinboardItem alloc] init];
	
	NSArray		*canonicalUrls	= [theItemDict valueForKeyPath:@"canonical"];
	NSArray		*alternateUrls	= [theItemDict valueForKeyPath:@"alternate"];
	NSString	*itemTitle		= [theItemDict valueForKeyPath:@"title"];
	NSString	*originTitle	= [theItemDict valueForKeyPath:@"origin.title"];
	NSString	*content		= [theItemDict valueForKeyPath:@"content.content"];
	NSArray		*categories		= [theItemDict valueForKeyPath:@"categories"];
	NSNumber	*published		= [theItemDict valueForKeyPath:@"published"];
	
	NSMutableArray *tagCategories = [NSMutableArray arrayWithCapacity:categories.count];
	for (NSString *category in categories) {
		NSArray *components = [category componentsSeparatedByString:@"/"];
		
		NSString	*tagComponent	= [components lastObject];
		BOOL		isGoogleTag		= (components.count == 5 && [(NSString *)[components objectAtIndex:3] isEqualToString:@"com.google"]);
		if (  (tagComponent && isGoogleTag	&& !(importOptions & PPGoogleReaderImportOmitGoogleTags))
			||(tagComponent && !isGoogleTag	&& !(importOptions & PPGoogleReaderImportOmitItemTags))
			) {
			[tagCategories addObject:tagComponent];
		}
	}
	
	item.url			= canonicalUrls.count > 0	? [NSURL URLWithString:[[canonicalUrls objectAtIndex:0] valueForKeyPath:@"href"]]	: nil;
	item.title			= itemTitle.length > 0		? itemTitle																			: nil;
	item.title			= originTitle.length > 0	? [item.title stringByAppendingFormat:@" [%@]",originTitle]							: item.title;
	item.descriptions	= content.length > 0		? content																			: nil;
	item.tags			= tagCategories.count > 0	? [NSArray arrayWithArray:tagCategories]											: @[];
	item.creationDate	= published.floatValue > 0	? [NSDate dateWithTimeIntervalSince1970:published.floatValue]						: nil;
	if (!item.url)
		item.url		= alternateUrls.count > 0	? [NSURL URLWithString:[[alternateUrls objectAtIndex:0] valueForKeyPath:@"href"]]	: nil;
	
	return (item.title.length > 0 && item.url) ? item : nil;
}

#pragma mark Public methods

- (BOOL)loadItemsAtUrl:(NSURL *)theFileUrl {
	self.items = nil;
	
	if (theFileUrl) {
		NSData *jsonData = [NSData dataWithContentsOfURL:theFileUrl];
		
		id jsonObject;
		if (jsonData.length > 0 && (jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL])) {
			NSArray *loadedItems = [jsonObject valueForKeyPath:@"items"];
			if (loadedItems.count > 0)
				self.items = loadedItems;
		}
	}
	
	return (self.items.count > 0);
}

@end
