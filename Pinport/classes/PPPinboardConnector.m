//
//  PPPinboardConnector.m
//  Pinport
//
//  Created by Michael on 04.05.13.
//  Copyright (c) 2013 mvanallen. All rights reserved.
//
//	Licenced under the MIT licence: http://www.opensource.org/licenses/MIT
//

#import "PPPinboardConnector.h"

#import "AFJSONRequestOperation.h"


#define PINBOARD_API_v1	@"https://api.pinboard.in/v1/"


@interface PPPinboardConnector (Private)
- (NSURL *)_apiCallForPath:(NSString *)theApiPath withParameters:(NSDictionary *)parameters token:(NSString *)aToken;
- (id)_resultForSynchronousApiRequest:(NSURLRequest *)theApiRequest withCredential:(NSURLCredential *)aCredential;
@end


@implementation PPPinboardConnector (Private)

- (NSURL *)_apiCallForPath:(NSString *)theApiPath withParameters:(NSDictionary *)parameters token:(NSString *)aToken {
	NSURL *url = nil;
	
	if (theApiPath.length > 0) {
		NSMutableArray *queryComponents = [NSMutableArray array];
		
		[queryComponents addObject:[@[@"format",@"json"] componentsJoinedByString:@"="]];
		
		if (aToken.length > 0)
			[queryComponents addObject:[@[@"auth_token",aToken] componentsJoinedByString:@"="]];
		
		for (id key in parameters.allKeys) {
			NSString *value = [parameters objectForKey:key];
			
			[queryComponents addObject:[@[key,value] componentsJoinedByString:@"="]];
		}
		
		NSString *apiCall = [NSString stringWithFormat:@"%@?%@",theApiPath,[queryComponents componentsJoinedByString:@"&"]];
		
		url = [NSURL URLWithString:apiCall relativeToURL:self.apiRootUrl];
	}
	
	return url;
}

- (id)_resultForSynchronousApiRequest:(NSURLRequest *)theApiRequest withCredential:(NSURLCredential *)aCredential {
	NSString __block *result = nil;
	
	if (theApiRequest) {
		dispatch_semaphore_t __block __communicationLock = dispatch_semaphore_create(0);
		
		AFHTTPRequestOperation *apiRequest = [[AFJSONRequestOperation alloc] initWithRequest:theApiRequest];
		
		[apiRequest setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
			
			if (aCredential) {
				[challenge.sender useCredential:aCredential forAuthenticationChallenge:challenge];
				//DLog(@"..authentication requested, sending credential %@..",aCredential);
				
			} else {
				[challenge.sender cancelAuthenticationChallenge:challenge];
				//DLog(@"..authentication requested but I ain't got no cred, aborting challenge..");
			}
		}];
		
		[apiRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			result = responseObject;
			
			dispatch_semaphore_signal(__communicationLock);
			//DLog(@"..request successful! (result: %@)",responseObject);
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			dispatch_semaphore_signal(__communicationLock);
			DLog(@"..request failed! (error: %@)",error);
		}];
		
		//DLog(@"Starting request..");
		[apiRequest start];
		
		dispatch_semaphore_wait(__communicationLock, DISPATCH_TIME_FOREVER);
	}
	
	return result;
}

@end


#pragma mark -


@implementation PPPinboardConnector

#pragma mark Initialization / Deallocation

- (id)init {
    self = [super init];
    if (self) {
		//
		
		if (![[AFJSONRequestOperation acceptableContentTypes] containsObject:@"text/plain"])		// Pinboard tends to declare JSON content
			[AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];	//  as 'plain' instead of 'json'..
    }
    return self;
}

#pragma mark Accessor methods

- (NSURL *)apiRootUrl {
	return [NSURL URLWithString:PINBOARD_API_v1];
}

#pragma mark Public methods

- (NSString *)authTokenForAccountWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
	NSString *token = nil;
	
	if (theUsername.length > 0 && thePassword.length > 0) {
		
		NSURLRequest *authRequest = [NSURLRequest requestWithURL:[self _apiCallForPath:@"user/api_token" withParameters:nil token:nil]
													 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
												 timeoutInterval:10.	];
		NSURLCredential *authCredential = [NSURLCredential credentialWithUser:theUsername
																	 password:thePassword
																  persistence:NSURLCredentialPersistenceNone	];
		
		id response = [self _resultForSynchronousApiRequest:authRequest withCredential:authCredential];
		
		if      ([response isKindOfClass:[NSData class]])
			token = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		
		else if ([response isKindOfClass:[NSDictionary class]])
			token = [response objectForKey:@"result"];
	}
	
	return token.length > 0 ? [@[theUsername,token] componentsJoinedByString:@":"] : nil;
}

- (NSString *)usingToken:(NSString *)theToken uploadItem:(PPPinboardItem *)anItem overwriteExisting:(BOOL)shouldReplaceExisting {
	NSString *result = nil;
	
	if (theToken.length > 0 && anItem && anItem.url && anItem.title.length > 0) {
		
		NSMutableDictionary *uploadParameters = [anItem.apiRepresentation mutableCopy];
		[uploadParameters setObject:shouldReplaceExisting ? @"yes" : @"no" forKey:@"replace"];
		
		NSURLRequest *addRequest = [NSURLRequest requestWithURL:[self _apiCallForPath:@"posts/add" withParameters:uploadParameters token:theToken]
													cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
												timeoutInterval:10.	];
		
		id response = [self _resultForSynchronousApiRequest:addRequest withCredential:nil];
		
		if ([response isKindOfClass:[NSDictionary class]])
			result = [response objectForKey:@"result_code"];
	}
	
	return result;
}

@end


#pragma mark -


@implementation PPPinboardItem

#pragma mark Initialization / Deallocation

- (id)init {
	return [self initWithUrl:nil andTitle:nil];
}

- (id)initWithUrl:(NSURL *)theUrl andTitle:(NSString *)theTitle {
    self = [super init];
    if (self) {
		self.url			= theUrl;
		self.title			= theTitle;
		self.descriptions	= nil;
		self.tags			= @[];
		self.creationDate	= nil;
		self.isPublic		= nil;
		self.isUnread		= nil;
    }
    return self;
}

#pragma mark Public methods

- (NSDictionary *)apiRepresentation {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat	= @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	dateFormatter.timeZone		= [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (self.url)
		[parameters setObject:self.url.absoluteString
					   forKey:@"url"			];
	if (self.title)
		[parameters setObject:[self.title.length > 255 ? [self.title substringToIndex:255] : self.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
					   forKey:@"description"	];
	if (self.descriptions)
		[parameters setObject:[self.descriptions.length > 65536 ? [self.descriptions substringToIndex:65536] : self.descriptions stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
					   forKey:@"extended"		];
	if (self.tags.count > 0)
		[parameters setObject:[[self.tags componentsJoinedByString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
					   forKey:@"tags"	];
	if (self.creationDate)
		[parameters setObject:[[dateFormatter stringFromDate:self.creationDate] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
					   forKey:@"dt"	];
	if (self.isPublic != nil)
		[parameters setObject:self.isPublic.boolValue ? @"yes" : @"no"
					   forKey:@"shared"	];
	if (self.isUnread != nil)
		[parameters setObject:self.isUnread.boolValue ? @"yes" : @"no"
					   forKey:@"toread"	];
	
	return parameters.count > 0 ? [NSDictionary dictionaryWithDictionary:parameters] : nil;
}

- (void)resolveURLRedirections {
	//DLog(@"Started w/ initial URL: '%@'",self.url);
	NSURL			*originalURL	= self.url;
	NSURL __block	*resolvedURL	= nil;
	
	if (self.url) {
		dispatch_semaphore_t __block __communicationLock = dispatch_semaphore_create(0);
		
		NSURLRequest *resolveRequest = [NSURLRequest requestWithURL:originalURL
														cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
													timeoutInterval:5.	];
		AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:resolveRequest];
		
		[request setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
			
			//DLog(@"..request encountered redirection to: '%@'",request.URL);
			
			if (redirectResponse)
				resolvedURL = [request.URL copy];
			
			return resolvedURL ? nil : request;
		}];
		
		[request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			dispatch_semaphore_signal(__communicationLock);
			//DLog(@"..request successful! (result: %@)",responseObject);
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			dispatch_semaphore_signal(__communicationLock);
			//DLog(@"..request failed! (error: %@)",error);
		}];
		
		[request start];
		
		dispatch_semaphore_wait(__communicationLock, DISPATCH_TIME_FOREVER);
	}
	
	if (resolvedURL)
		self.url = resolvedURL;
	
	DLog(@"Resolved URL '%@' to '%@'",originalURL,resolvedURL);
}

- (NSString *)description {
	NSMutableString *desc = [NSMutableString string];
	
	[desc appendFormat:@"%@ { ",NSStringFromClass(self.class)];
	[desc appendFormat:@" %@ = '%@',",@"title",self.title];
	[desc appendFormat:@" %@ = '%@',",@"url",self.url];
	[desc appendFormat:@" %@ = '%@',",@"desc",[self.descriptions substringToIndex:MAX(self.descriptions.length,150)]];
	[desc appendFormat:@" %@ = [%@],",@"tags",[self.tags componentsJoinedByString:@" "]];
	[desc appendFormat:@" %@ = '%@',",@"date",self.creationDate];
	[desc appendFormat:@" %@ = '%@',",@"public",self.isPublic.boolValue?@"YES":@"NO"];
	[desc appendFormat:@" %@ = '%@'" ,@"unread",self.isUnread.boolValue?@"YES":@"NO"];
	[desc appendString:@" }"];
	
	return desc;
}

@end
