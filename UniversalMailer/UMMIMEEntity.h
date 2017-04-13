//
//  UMMIMEEntity.h
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMMIMEBody: NSObject
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSArray *subentities;

- (id)initWithString: (NSString*)string;
- (id)initWithSubentities: (NSArray*)entities;

@end

@interface UMMIMEEntity : NSObject
@property (nonatomic, strong) NSString* originalHeaders;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) UMMIMEBody *body;

@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *contentID;
@property (nonatomic, strong) NSString *charset;
@property (nonatomic, strong) NSString *contentDisposition;
@property (nonatomic, strong) NSString *contentTransferEncoding;

- (id)initWithContentType: (NSString*)contentType;
- (id)initWithString: (NSString*)string;
- (id)initWithData: (NSData*)data;

- (NSString*)bodyString;
- (NSString*)encodedBodyString;

- (NSArray*)findSubentitiesOfType: (NSString*)type avoidAttachments: (BOOL)avoidAttachments invertMatches: (BOOL)invertMatches;

- (void)parseHeadersFromString: (NSString*)string;

- (void)setContentTypeParameterWithKey: (NSString*)key value: (NSString*)value;

@end
