//
//  PPPinboardConnector.h
//  Pinport
//
//  Created by Michael on 04.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//
//	Licenced under the MIT licence: http://www.opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>


@class PPPinboardItem;

@interface PPPinboardConnector : NSObject
@property (nonatomic,readonly)	NSURL			*apiRootUrl;
@property (nonatomic,readonly)	NSTimeInterval	defaultRequestDelay;

- (NSString *)authTokenForAccountWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;
- (NSString *)usingToken:(NSString *)theToken uploadItem:(PPPinboardItem *)anItem overwriteExisting:(BOOL)shouldReplaceExisting httpError:(NSError **)error;
@end


@interface PPPinboardItem : NSObject

@property (nonatomic,strong)	NSURL		*url;
@property (nonatomic,strong)	NSString	*title;
@property (nonatomic,strong)	NSString	*descriptions;
@property (nonatomic,strong)	NSArray		*tags;
@property (nonatomic,strong)	NSDate		*creationDate;
@property (nonatomic,strong)	NSNumber	*isPublic;
@property (nonatomic,strong)	NSNumber	*isUnread;

- (id)initWithUrl:(NSURL *)theUrl andTitle:(NSString *)theTitle;
- (NSDictionary *)apiRepresentation;
- (void)resolveURLRedirections;
@end
