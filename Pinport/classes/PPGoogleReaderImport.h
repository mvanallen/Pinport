//
//  PPGoogleReaderImport.h
//  Pinport
//
//  Created by Michael on 04.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, PPGoogleReaderImportOptions) {
    PPGoogleReaderImportOmitGoogleTags	= (1UL << 0),
    PPGoogleReaderImportOmitItemTags	= (1UL << 1)
};


@class PPPinboardItem;

@interface PPGoogleReaderImport : NSObject
@property (nonatomic,strong)	NSArray	*items;

+ (PPPinboardItem *)pinboardItemFromGoogleReaderItem:(NSDictionary *)theItemDict options:(PPGoogleReaderImportOptions)importOptions;
- (BOOL)loadItemsAtUrl:(NSURL *)theFileUrl;
@end
